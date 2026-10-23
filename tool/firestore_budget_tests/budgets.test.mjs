import {readFile} from 'node:fs/promises';
import {before, after, beforeEach, test} from 'node:test';
import {initializeTestEnvironment, assertFails, assertSucceeds} from '@firebase/rules-unit-testing';
import {doc, setDoc, getDoc, deleteDoc, updateDoc, serverTimestamp, Timestamp, collection, getDocs} from 'firebase/firestore';

let env;
const projectId = 'demo-billey-budget';
const path = 'users/alice/categoryBudgets/2026-10_COP_food';
const data = () => ({userId:'alice', month:'2026-10', categoryId:'food',
  categoryName:'Comida', currency:'COP', limit:200000, updatedAt:serverTimestamp()});
before(async () => {
  env = await initializeTestEnvironment({projectId, firestore:{host:'127.0.0.1',port:8787,
    rules:await readFile(new URL('../../firestore.rules', import.meta.url),'utf8')}});
});
after(async () => {await env?.cleanup();});
beforeEach(async () => {await env.clearFirestore();});
const db = (uid) => uid ? env.authenticatedContext(uid).firestore() : env.unauthenticatedContext().firestore();

test('owner can create, read, list, update and remove their budget', async () => {
  const owner = db('alice'); const ref = doc(owner,path);
  await assertSucceeds(setDoc(ref,data()));
  await assertSucceeds(getDoc(ref));
  await assertSucceeds(getDocs(collection(owner,'users/alice/categoryBudgets')));
  await assertSucceeds(updateDoc(ref,{limit:250000,updatedAt:serverTimestamp()}));
  await assertSucceeds(deleteDoc(ref));
});
test('unauthenticated and other accounts cannot read or write budgets', async () => {
  await assertSucceeds(setDoc(doc(db('alice'),path),data()));
  for (const user of [null,'bob']) {
    const ref = doc(db(user),path);
    await assertFails(getDoc(ref)); await assertFails(setDoc(ref,data()));
    await assertFails(deleteDoc(ref));
  }
});
test('partner permission on the parent user does not expose budgets', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    const admin = context.firestore();
    await setDoc(doc(admin,'users/alice'),{uid:'alice',coupleId:'couple'});
    await setDoc(doc(admin,'couples/couple'),{memberUids:['alice','bob']});
    await setDoc(doc(admin,path),{...data(),updatedAt:Timestamp.fromMillis(0)});
  });
  await assertSucceeds(getDoc(doc(db('bob'),'users/alice')));
  await assertFails(getDoc(doc(db('bob'),path)));
});
test('invalid money, month, currency, identity, timestamps and extra fields fail', async () => {
  const ref=doc(db('alice'),path);
  for (const change of [{limit:0},{limit:-10},{limit:Infinity},{limit:NaN},{limit:'200'},
    {limit:1e12+1},{month:'2026-13'},{currency:'ABC'},{categoryId:'transport'},
    {userId:'bob'},{updatedAt:Timestamp.fromMillis(0)},{unexpected:true},
    {categoryName:''}]) {
    await assertFails(setDoc(ref,{...data(),...change}));
  }
  await assertFails(setDoc(doc(db('alice'),'users/alice/categoryBudgets/another-id'),data()));
});
test('months and custom categories can have independent budgets', async () => {
  const owner=db('alice');
  await assertSucceeds(setDoc(doc(owner,path),data()));
  await assertSucceeds(setDoc(doc(owner,'users/alice/categoryBudgets/2026-11_COP_custom_123'),
    {...data(),month:'2026-11',categoryId:'custom_123',categoryName:'Mascotas',limit:50000}));
});
