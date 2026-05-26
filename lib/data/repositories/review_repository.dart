import 'package:bol_il_bwa/domain/entities/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviewsByToiletId(String toiletId);

  Future<Review?> getReviewById(String reviewId);

  Future<void> addReview(Review review);

  Future<void> updateReview(Review review);

  Future<void> deleteReview(String reviewId);
}
