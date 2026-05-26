import 'package:bol_il_bwa/domain/entities/password_share.dart';

abstract class PasswordRepository {
  Future<List<PasswordShare>> getPasswordsByToiletId(String toiletId);

  Future<PasswordShare?> getPasswordById(String passwordId);

  Future<void> addPassword(PasswordShare password);

  Future<void> deletePassword(String passwordId);

  Future<void> likePassword(String passwordId);
}
