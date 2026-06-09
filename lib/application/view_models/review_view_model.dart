import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bol_il_bwa/domain/entities/review.dart';
import 'package:bol_il_bwa/data/repositories/review_repository.dart';
import 'package:bol_il_bwa/application/state/toilet_state.dart';
import 'package:bol_il_bwa/application/providers/repository_providers.dart';
import 'package:bol_il_bwa/application/providers/user_provider.dart';

class ReviewViewModel extends StateNotifier<ReviewScreenState> {
  final ReviewRepository _reviewRepository;
  final String _userId;

  ReviewViewModel(this._reviewRepository, this._userId)
      : super(const ReviewScreenState());

  void setRating(int rating) {
    state = state.copyWith(selectedRating: rating);
  }

  void setComment(String comment) {
    state = state.copyWith(comment: comment);
  }

  Future<bool> submitReview(String toiletId) async {
    if (state.selectedRating == 0) {
      state = state.copyWith(error: '별점을 선택해주세요');
      return false;
    }
    if (state.comment.isEmpty) {
      state = state.copyWith(error: '리뷰 내용을 입력해주세요');
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final review = Review(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        toiletId: toiletId,
        userId: _userId,
        rating: state.selectedRating,
        comment: state.comment,
        createdAt: DateTime.now(),
      );
      await _reviewRepository.addReview(review);
      state = state.copyWith(isSubmitting: false, selectedRating: 0, comment: '');
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  void resetForm() => state = const ReviewScreenState();
}

final reviewViewModelProvider =
    StateNotifierProvider<ReviewViewModel, ReviewScreenState>((ref) {
  return ReviewViewModel(
    ref.read(reviewRepositoryProvider),
    ref.read(currentUserIdProvider),
  );
});
