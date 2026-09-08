import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Whether the signed-in account has finished the profile-setup wizard
/// (personal data, goals, income distribution). Stored in Firestore
/// `users/{uid}.onboardingCompleted` — properly scoped per account
/// server-side, with none of the local-storage migration/ordering
/// footguns a device-local flag would carry across account switches.
class OnboardingStatus {
  const OnboardingStatus._();

  static Future<bool> hasCompleted() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data()?['onboardingCompleted'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> markCompleted() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {'uid': user.uid, 'onboardingCompleted': true},
      SetOptions(merge: true),
    );
  }
}
