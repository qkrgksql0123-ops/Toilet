import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bol_il_bwa/domain/entities/review.dart';
import 'package:bol_il_bwa/domain/entities/password_share.dart';
import 'package:bol_il_bwa/data/repositories/toilet_repository.dart';
import 'package:bol_il_bwa/data/repositories/review_repository.dart';
import 'package:bol_il_bwa/data/repositories/password_repository.dart';
import 'package:bol_il_bwa/application/state/toilet_state.dart';
import 'package:bol_il_bwa/application/providers/repository_providers.dart';
import 'package:bol_il_bwa/application/providers/user_provider.dart';

class ToiletViewModel extends StateNotifier<ToiletDetailState> {
  final ToiletRepository _toiletRepository;
  final ReviewRepository _reviewRepository;
  final PasswordRepository _passwordRepository;
  final String _userId;

  ToiletViewModel(
    this._toiletRepository,
    this._reviewRepository,
    this._passwordRepository,
    this._userId,
  ) : super(const ToiletDetailState());

  Future<void> loadToiletDetail(String toiletId) async {
    state = state.copyWith(isLoading: true, error: null);

    // 화장실 기본 정보 먼저 로드 - 실패 시 오류 표시
    try {
      final toilet = await _toiletRepository.getToiletById(toiletId);
      state = state.copyWith(toilet: toilet, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return;
    }

    // 리뷰, 비번은 별도로 로드 - 실패해도 화장실 정보는 유지
    try {
      final reviews = await _reviewRepository.getReviewsByToiletId(toiletId);
      state = state.copyWith(reviews: reviews);
    } catch (_) {}

    try {
      final passwords = await _passwordRepository.getPasswordsByToiletId(toiletId);
      state = state.copyWith(passwords: passwords);
    } catch (_) {}
  }

  Future<void> addReview(String toiletId, int rating, String comment) async {
    try {
      final review = Review(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        toiletId: toiletId,
        userId: _userId,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );
      await _reviewRepository.addReview(review);
      final reviews = await _reviewRepository.getReviewsByToiletId(toiletId);
      state = state.copyWith(reviews: reviews);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addPassword(String toiletId, String password) async {
    try {
      final pw = PasswordShare(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        toiletId: toiletId,
        password: password,
        userId: _userId,
        likes: 0,
        createdAt: DateTime.now(),
      );
      await _passwordRepository.addPassword(pw);
      final passwords = await _passwordRepository.getPasswordsByToiletId(toiletId);
      state = state.copyWith(passwords: passwords);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> likePassword(String passwordId) async {
    try {
      await _passwordRepository.likePassword(passwordId);
      final updatedPasswords = state.passwords.map((pw) {
        if (pw.id == passwordId) return pw.copyWith(likes: pw.likes + 1);
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
    ref.read(currentUserIdProvider),
  );
});
