import 'package:flutter/material.dart';
import 'package:bol_il_bwa/presentation/theme/app_theme.dart';
import 'package:bol_il_bwa/presentation/screens/map_screen.dart';
import 'package:bol_il_bwa/presentation/screens/toilet_detail_screen.dart';
import 'package:bol_il_bwa/presentation/screens/review_screen.dart';
import 'package:bol_il_bwa/presentation/screens/favorites_screen.dart';
import 'package:bol_il_bwa/presentation/screens/password_screen.dart';

class BolIlBwaApp extends StatelessWidget {
  const BolIlBwaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '볼일봐',
      theme: AppTheme.lightTheme,
      home: const MapScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/map':
            return MaterialPageRoute(
              builder: (context) => const MapScreen(),
            );
          case '/toilet-detail':
            final toiletId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ToiletDetailScreen(toiletId: toiletId),
            );
          case '/review':
            final toiletId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ReviewScreen(toiletId: toiletId),
            );
          case '/favorites':
            return MaterialPageRoute(
              builder: (context) => const FavoritesScreen(),
            );
          case '/password':
            return MaterialPageRoute(
              builder: (context) => const PasswordScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const MapScreen(),
            );
        }
      },
    );
  }
}
