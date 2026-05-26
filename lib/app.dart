import 'package:flutter/material.dart';
import 'package:bol_il_bwa/presentation/theme/app_theme.dart';

class BolIlBwaApp extends StatelessWidget {
  const BolIlBwaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '볼일봐',
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text('볼일봐 - 공중화장실 지도'),
        ),
      ),
    );
  }
}
