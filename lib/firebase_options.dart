import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS는 GoogleService-Info.plist 설정 필요');
      default:
        throw UnsupportedError('지원하지 않는 플랫폼');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDmK-AnM2QTyXspu7qAFIKe5f1xHk-OlxY',
    appId: '1:572356889580:web:a3f0ebc02f0eca61b68ec9',
    messagingSenderId: '572356889580',
    projectId: 'toilet-bolilbwa',
    storageBucket: 'toilet-bolilbwa.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDmK-AnM2QTyXspu7qAFIKe5f1xHk-OlxY',
    appId: '1:572356889580:android:a3f0ebc02f0eca61b68ec9',
    messagingSenderId: '572356889580',
    projectId: 'toilet-bolilbwa',
    storageBucket: 'toilet-bolilbwa.firebasestorage.app',
  );
}
