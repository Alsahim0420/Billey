import { setGlobalOptions } from "firebase-functions/v2";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

admin.initializeApp();
setGlobalOptions({ region: "us-central1", maxInstances: 10 });

const db = admin.firestore();

const CODE_TTL_MS = 5 * 60 * 1000; // 5 minutes
const CODE_LENGTH = 6;

function requireUid(auth: { uid: string } | undefined): string {
  if (!auth) {
    throw new HttpsError("unauthenticated", "Debes iniciar sesión.");
  }
  return auth.uid;
}

function randomSixDigitCode(): string {
  const value = Math.floor(Math.random() * 1_000_000);
  return value.toString().padStart(CODE_LENGTH, "0");
}

/**
 * Generates (or refreshes) the caller's 6-digit pairing code. Any previous
 * code for this user is invalidated. The code expires in 5 minutes; the
 * client re-calls this function on a timer while the pairing screen is
 * open to give the appearance of a code that "rotates every 5 minutes"
 * without needing an always-on scheduled function.
 */
export const generatePairingCode = onCall(async (request) => {
  const uid = requireUid(request.auth);

  const userSnap = await db.collection("users").doc(uid).get();
  if (userSnap.exists && userSnap.data()?.coupleId) {
    throw new HttpsError(
      "failed-precondition",
      "Ya tienes una pareja vinculada. Desvincúlate primero."
    );
  }

  // Invalidate any previous codes owned by this user.
  const previous = await db
    .collection("pairingCodes")
    .where("ownerUid", "==", uid)
    .get();
  const cleanupBatch = db.batch();
  previous.docs.forEach((doc) => cleanupBatch.delete(doc.ref));
  await cleanupBatch.commit();

  // Generate a code that isn't currently in use (extremely unlikely to
  // collide, but check anyway since codes must be unique while active).
  let code = "";
  for (let attempt = 0; attempt < 5; attempt++) {
    const candidate = randomSixDigitCode();
    const existing = await db.collection("pairingCodes").doc(candidate).get();
    if (!existing.exists) {
      code = candidate;
      break;
    }
  }
  if (!code) {
    throw new HttpsError("resource-exhausted", "No se pudo generar un código, intenta de nuevo.");
  }

  const now = Date.now();
  const expiresAtMillis = now + CODE_TTL_MS;
  await db
    .collection("pairingCodes")
    .doc(code)
    .set({
      code,
      ownerUid: uid,
      createdAt: admin.firestore.Timestamp.fromMillis(now),
      expiresAt: admin.firestore.Timestamp.fromMillis(expiresAtMillis),
    });

  return { code, expiresAtMillis };
});

/**
 * Redeems a partner's pairing code, creating the couple link between both
 * accounts. One-time use: the code is deleted once redeemed.
 */
export const redeemPairingCode = onCall(async (request) => {
  const uid = requireUid(request.auth);
  const code = String(request.data?.code ?? "").trim();

  if (!/^\d{6}$/.test(code)) {
    throw new HttpsError("invalid-argument", "El código debe tener 6 dígitos.");
  }

  const codeRef = db.collection("pairingCodes").doc(code);
  const codeSnap = await codeRef.get();
  if (!codeSnap.exists) {
    throw new HttpsError("not-found", "Ese código no existe o ya expiró.");
  }

  const codeData = codeSnap.data()!;
  const ownerUid = codeData.ownerUid as string;
  const expiresAt = (codeData.expiresAt as admin.firestore.Timestamp).toMillis();

  if (Date.now() > expiresAt) {
    await codeRef.delete();
    throw new HttpsError("deadline-exceeded", "Ese código ya expiró. Pide uno nuevo.");
  }
  if (ownerUid === uid) {
    throw new HttpsError("invalid-argument", "No puedes usar tu propio código.");
  }

  const myRef = db.collection("users").doc(uid);
  const partnerRef = db.collection("users").doc(ownerUid);
  const [mySnap, partnerSnap] = await Promise.all([myRef.get(), partnerRef.get()]);

  if (mySnap.exists && mySnap.data()?.coupleId) {
    throw new HttpsError("failed-precondition", "Ya tienes una pareja vinculada.");
  }
  if (partnerSnap.exists && partnerSnap.data()?.coupleId) {
    // The code owner linked with someone else in the meantime.
    await codeRef.delete();
    throw new HttpsError("failed-precondition", "Esa persona ya tiene una pareja vinculada.");
  }

  const coupleRef = db.collection("couples").doc();
  const batch = db.batch();
  batch.set(coupleRef, {
    memberUids: [ownerUid, uid],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  batch.set(myRef, { coupleId: coupleRef.id }, { merge: true });
  batch.set(partnerRef, { coupleId: coupleRef.id }, { merge: true });
  batch.delete(codeRef);
  await batch.commit();

  return {
    coupleId: coupleRef.id,
    partnerUid: ownerUid,
    partnerDisplayName: (partnerSnap.data()?.displayName as string | undefined) ?? "",
  };
});

/** Removes the caller's active couple link (either partner can unlink). */
export const unlinkCouple = onCall(async (request) => {
  const uid = requireUid(request.auth);

  const myRef = db.collection("users").doc(uid);
  const mySnap = await myRef.get();
  const coupleId = mySnap.data()?.coupleId as string | undefined;
  if (!coupleId) {
    throw new HttpsError("failed-precondition", "No tienes ninguna pareja vinculada.");
  }

  const coupleRef = db.collection("couples").doc(coupleId);
  const coupleSnap = await coupleRef.get();
  const memberUids = (coupleSnap.data()?.memberUids as string[] | undefined) ?? [uid];

  const batch = db.batch();
  batch.delete(coupleRef);
  for (const memberUid of memberUids) {
    batch.set(
      db.collection("users").doc(memberUid),
      { coupleId: admin.firestore.FieldValue.delete() },
      { merge: true }
    );
  }
  await batch.commit();

  return { success: true };
});
