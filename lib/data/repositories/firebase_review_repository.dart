import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bol_il_bwa/data/repositories/review_repository.dart';
import 'package:bol_il_bwa/domain/entities/review.dart';

class FirebaseReviewRepository implements ReviewRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection('reviews');

  Review _fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final raw = d['createdAt'];
    final createdAt = raw is Timestamp
        ? raw.toDate()
        : raw is String
            ? DateTime.parse(raw)
            : DateTime.now();
    return Review(
      id: doc.id,
      toiletId: d['toiletId'] as String,
      userId: d['userId'] as String? ?? '익명',
      rating: (d['rating'] as num).toInt(),
      comment: d['comment'] as String? ?? '',
      createdAt: createdAt,
    );
  }

  @override
  Future<List<Review>> getReviewsByToiletId(String toiletId) async {
    // orderBy 제거 - Firestore 복합 인덱스 없이 단순 where 쿼리
    final snap = await _col.where('toiletId', isEqualTo: toiletId).get();
    final list = snap.docs.map(_fromDoc).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<List<Review>> getReviewsByUserId(String userId) async {
    final snap = await _col.where('userId', isEqualTo: userId).get();
    final list = snap.docs.map(_fromDoc).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<Review?> getReviewById(String reviewId) async {
    final doc = await _col.doc(reviewId).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  @override
  Future<void> addReview(Review review) async {
    await _col.add({
      'toiletId': review.toiletId,
      'userId': review.userId,
      'rating': review.rating,
      'comment': review.comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _updateAvgRating(review.toiletId);
  }

  @override
  Future<void> updateReview(Review review) async {
    await _col.doc(review.id).update({
      'rating': review.rating,
      'comment': review.comment,
    });
    await _updateAvgRating(review.toiletId);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await _col.doc(reviewId).delete();
  }

  Future<void> _updateAvgRating(String toiletId) async {
    final snap = await _col.where('toiletId', isEqualTo: toiletId).get();
    if (snap.docs.isEmpty) return;
    final ratings = snap.docs
        .map((d) => ((d.data() as Map)['rating'] as num).toDouble())
        .toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;
    await _db
        .collection('toilets')
        .doc(toiletId)
        .set({'avgRating': avg}, SetOptions(merge: true));
  }
}
