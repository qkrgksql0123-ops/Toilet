import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bol_il_bwa/data/repositories/toilet_repository.dart';
import 'package:bol_il_bwa/data/repositories/review_repository.dart';
import 'package:bol_il_bwa/data/repositories/password_repository.dart';
import 'package:bol_il_bwa/data/repositories/mock_toilet_repository.dart';
import 'package:bol_il_bwa/data/repositories/mock_review_repository.dart';
import 'package:bol_il_bwa/data/repositories/mock_password_repository.dart';

final toiletRepositoryProvider = Provider<ToiletRepository>((ref) {
  return MockToiletRepository();
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return MockReviewRepository();
});

final passwordRepositoryProvider = Provider<PasswordRepository>((ref) {
  return MockPasswordRepository();
});
