import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bol_il_bwa/data/repositories/password_repository.dart';
import 'package:bol_il_bwa/domain/entities/password_share.dart';

class FirebasePasswordRepository implements PasswordRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection('passwords');

  PasswordShare _fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final raw = d['createdAt'];
    final createdAt = raw is Timestamp
        ? raw.toDate()
        : raw is String
            ? DateTime.parse(raw)
            : DateTime.now();
    return PasswordShare(
      id: doc.id,
      toiletId: d['toiletId'] as String,
      password: d['password'] as String,
      userId: d['userId'] as String? ?? '익명',
      likes: (d['likes'] as num? ?? 0).toInt(),
      createdAt: createdAt,
    );
  }

  @override
  Future<List<PasswordShare>> getPasswordsByToiletId(String toiletId) async {
    // orderBy 제거 - Firestore 복합 인덱스 없이 단순 where 쿼리
    final snap = await _col.where('toiletId', isEqualTo: toiletId).get();
    final list = snap.docs.map(_fromDoc).toList();
    list.sort((a, b) => b.likes.compareTo(a.likes));
    return list;
  }

  @override
  Future<List<PasswordShare>> getPasswordsByUserId(String userId) async {
    final snap = await _col.where('userId', isEqualTo: userId).get();
    final list = snap.docs.map(_fromDoc).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<PasswordShare?> getPasswordById(String passwordId) async {
    final doc = await _col.doc(passwordId).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  @override
  Future<void> addPassword(PasswordShare password) async {
    await _col.add({
      'toiletId': password.toiletId,
      'password': password.password,
      'userId': password.userId,
      'likes': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deletePassword(String passwordId) async {
    await _col.doc(passwordId).delete();
  }

  @override
  Future<void> likePassword(String passwordId) async {
    await _col.doc(passwordId).update({
      'likes': FieldValue.increment(1),
    });
  }
}
