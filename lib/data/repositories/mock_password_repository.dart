import 'package:bol_il_bwa/domain/entities/password_share.dart';
import 'package:bol_il_bwa/data/repositories/password_repository.dart';
import 'package:bol_il_bwa/data/mock/mock_data.dart';

class MockPasswordRepository implements PasswordRepository {
  final List<PasswordShare> _passwords = [
    ...MockData.passwordsForToilet2,
    ...MockData.passwordsForToilet5,
  ];

  @override
  Future<List<PasswordShare>> getPasswordsByToiletId(String toiletId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _passwords.where((pw) => pw.toiletId == toiletId).toList();
  }

  @override
  Future<PasswordShare?> getPasswordById(String passwordId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _passwords.firstWhere((pw) => pw.id == passwordId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addPassword(PasswordShare password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _passwords.add(password);
  }

  @override
  Future<void> deletePassword(String passwordId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _passwords.removeWhere((pw) => pw.id == passwordId);
  }

  @override
  Future<void> likePassword(String passwordId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _passwords.indexWhere((pw) => pw.id == passwordId);
    if (index >= 0) {
      _passwords[index] = _passwords[index].copyWith(
        likes: _passwords[index].likes + 1,
      );
    }
  }
}
