import 'package:flutter_riverpod/flutter_riverpod.dart';

// 세션 단위 익명 사용자 ID - 앱 재시작 시 새로 생성
final currentUserIdProvider = Provider<String>((ref) {
  return 'user_${DateTime.now().millisecondsSinceEpoch}';
});
