// Firebase Firestore 연동
let db;

function initFirebase() {
  try {
    firebase.initializeApp(CONFIG.FIREBASE);
    db = firebase.firestore();
    console.log('[Firebase] 초기화 성공, projectId:', CONFIG.FIREBASE.projectId);
  } catch (e) {
    console.error('[Firebase] 초기화 실패:', e.message);
  }
}

// 익명 사용자 ID (세션 유지)
function getUserId() {
  let uid = sessionStorage.getItem('uid');
  if (!uid) {
    uid = 'anon_' + Math.random().toString(36).slice(2, 10);
    sessionStorage.setItem('uid', uid);
  }
  return uid;
}

// 리뷰 조회
async function getReviews(toiletId) {
  const snap = await db
    .collection('toilets').doc(toiletId)
    .collection('reviews')
    .orderBy('createdAt', 'desc')
    .limit(20)
    .get();
  return snap.docs.map(d => ({ id: d.id, ...d.data() }));
}

// 리뷰 추가
async function addReview(toiletId, rating, comment) {
  console.log('[Firebase] 리뷰 저장 시도:', toiletId, rating, comment);
  await db.collection('toilets').doc(toiletId).collection('reviews').add({
    userId: getUserId(),
    rating,
    comment,
    createdAt: firebase.firestore.FieldValue.serverTimestamp(),
  });
  // 평균 평점 업데이트
  const reviews = await getReviews(toiletId);
  const avg = reviews.reduce((s, r) => s + r.rating, 0) / reviews.length;
  await db.collection('toilets').doc(toiletId).set({ avgRating: avg }, { merge: true });
}

// 비밀번호 목록 조회
async function getPasswords(toiletId) {
  const snap = await db
    .collection('toilets').doc(toiletId)
    .collection('passwords')
    .orderBy('likes', 'desc')
    .limit(10)
    .get();
  return snap.docs.map(d => ({ id: d.id, ...d.data() }));
}

// 비밀번호 추가
async function addPassword(toiletId, password) {
  await db.collection('toilets').doc(toiletId).collection('passwords').add({
    userId: getUserId(),
    password,
    likes: 0,
    createdAt: firebase.firestore.FieldValue.serverTimestamp(),
  });
}

// 비밀번호 좋아요
async function likePassword(toiletId, passwordId) {
  const ref = db
    .collection('toilets').doc(toiletId)
    .collection('passwords').doc(passwordId);
  await ref.update({ likes: firebase.firestore.FieldValue.increment(1) });
}

// 화장실 평균 평점 조회
async function getToiletMeta(toiletId) {
  const doc = await db.collection('toilets').doc(toiletId).get();
  return doc.exists ? doc.data() : { avgRating: 0 };
}
