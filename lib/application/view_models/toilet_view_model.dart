import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bol_il_bwa/domain/entities/review.dart';
import 'package:bol_il_bwa/data/repositories/toilet_repository.dart';
import 'package:bol_il_bwa/data/repositories/review_repository.dart';
import 'package:bol_il_bwa/data/repositories/password_repository.dart';
import 'package:bol_il_bwa/application/state/toilet_state.dart';
import 'package:bol_il_bwa/application/providers/repository_providers.dart';

class ToiletViewModel extends StateNotifier<ToiletDetailState> {
  final ToiletRepository _toiletRepository;
  final ReviewRepository _reviewRepository;
  final PasswordRepository _passwordRepository;

  ToiletViewModel(
    this._toiletRepository,
    this._reviewRepository,
    this._passwordRepository,
  ) : super(const ToiletDetailState());

  Future<void> loadToiletDetail(String toiletId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final toilet = await _toiletRepository.getToiletById(toiletId);
      final reviews = await _reviewRepository.getReviewsByToiletId(toiletId);
      final passwords = await _passwordRepository.getPasswordsByToiletId(toiletId);

      state = state.copyWith(
        toilet: toilet,
        reviews: reviews,
        passwords: passwords,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addReview(String toiletId, int rating, String comment) async {
    try {
      final review = Review(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        toiletId: toiletId,
        userId: '익명 사용자',
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await _reviewRepository.addReview(review);

      // 리뷰 목록 다시 로드
      final reviews = await _reviewRepository.getReviewsByToiletId(toiletId);
      state = state.copyWith(reviews: reviews);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addPassword(String toiletId, String password) async {
    try {
      // 비밀번호 목록 다시 로드
      final passwords = await _passwordRepository.getPasswordsByToiletId(toiletId);
      state = state.copyWith(passwords: passwords);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> likePassword(String passwordId) async {
    try {
      await _passwordRepository.likePassword(passwordId);

      // 현재 화면의 비밀번호 목록 업데이트
      final updatedPasswords = state.passwords.map((pw) {
        if (pw.id == passwordId) {
          return pw.copyWith(likes: pw.likes + 1);
        }
        return pw;
      }).toList();

      state = state.copyWith(passwords: updatedPasswords);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final toiletViewModelProvider =
    StateNotifierProvider<ToiletViewModel, ToiletDetailState>((ref) {
  return ToiletViewModel(
    ref.read(toiletRepositoryProvider),
    ref.read(reviewRepositoryProvider),
    ref.read(passwordRepositoryProvider),
  );
});
