import 'package:bol_il_bwa/domain/entities/review.dart';
import 'package:bol_il_bwa/data/repositories/review_repository.dart';
import 'package:bol_il_bwa/data/mock/mock_data.dart';

class MockReviewRepository implements ReviewRepository {
  final List<Review> _reviews = [
    ...MockData.reviewsForToilet1,
    ...MockData.reviewsForToilet2,
  ];

  @override
  Future<List<Review>> getReviewsByToiletId(String toiletId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _reviews.where((review) => review.toiletId == toiletId).toList();
  }

  @override
  Future<Review?> getReviewById(String reviewId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _reviews.firstWhere((review) => review.id == reviewId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addReview(Review review) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _reviews.add(review);
  }

  @override
  Future<void> updateReview(Review review) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _reviews.indexWhere((r) => r.id == review.id);
    if (index >= 0) {
      _reviews[index] = review;
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _reviews.removeWhere((review) => review.id == reviewId);
  }
}
