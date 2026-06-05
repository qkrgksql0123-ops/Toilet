import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bol_il_bwa/domain/entities/toilet.dart';
import 'package:bol_il_bwa/domain/entities/password_share.dart';
import 'package:bol_il_bwa/data/repositories/toilet_repository.dart';
import 'package:bol_il_bwa/data/repositories/password_repository.dart';
import 'package:bol_il_bwa/application/state/toilet_state.dart';
import 'package:bol_il_bwa/application/providers/repository_providers.dart';

class PasswordViewModel extends StateNotifier<PasswordScreenState> {
  final ToiletRepository _toiletRepository;
  final PasswordRepository _passwordRepository;

  PasswordViewModel(this._toiletRepository, this._passwordRepository)
      : super(const PasswordScreenState());

  Future<void> loadLockedToilets() async {
    try {
      final toilets = await _toiletRepository.getAllToilets();
      final lockedToilets = toilets.where((t) => t.isLocked).toList();
      state = state.copyWith(lockedToilets: lockedToilets);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void selectToilet(String toiletId) {
    state = state.copyWith(selectedToiletId: toiletId);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password);
  }

  Toilet? getSelectedToilet() {
    if (state.selectedToiletId == null) return null;
    try {
      return state.lockedToilets
          .firstWhere((t) => t.id == state.selectedToiletId);
    } catch (e) {
      return null;
    }
  }

  Future<List<PasswordShare>> getPasswordsForToilet(String toiletId) async {
    try {
      return await _passwordRepository.getPasswordsByToiletId(toiletId);
    } catch (e) {
      return [];
    }
  }

  Future<bool> submitPassword() async {
    if (state.selectedToiletId == null) {
      state = state.copyWith(error: '화장실을 선택해주세요');
      return false;
    }

    if (state.password.isEmpty) {
      state = state.copyWith(error: '비밀번호를 입력해주세요');
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final passwordShare = PasswordShare(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        toiletId: state.selectedToiletId!,
        password: state.password,
        userId: '익명 사용자',
        likes: 0,
        createdAt: DateTime.now(),
      );

      await _passwordRepository.addPassword(passwordShare);

      state = state.copyWith(
        isSubmitting: false,
        password: '',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> likePassword(String passwordId) async {
    try {
      await _passwordRepository.likePassword(passwordId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void resetForm() {
    state = state.copyWith(
      selectedToiletId: null,
      password: '',
      error: null,
    );
  }
}

final passwordViewModelProvider =
    StateNotifierProvider<PasswordViewModel, PasswordScreenState>((ref) {
  return PasswordViewModel(
    ref.read(toiletRepositoryProvider),
    ref.read(passwordRepositoryProvider),
  );
});
