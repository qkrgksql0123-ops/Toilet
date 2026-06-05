import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import 'app.dart';
import 'firebase_options.dart';

export 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 카카오 지도 SDK 초기화 (JavaScript 앱 키 필요)
  AuthRepository.initialize(appKey: dotenv.env['KAKAO_JS_KEY'] ?? '');

  runApp(const ProviderScope(child: BolIlBwaApp()));
}
