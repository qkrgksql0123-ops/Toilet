import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:bol_il_bwa/presentation/theme/app_theme.dart';
import 'package:bol_il_bwa/presentation/widgets/password_card.dart';
import 'package:bol_il_bwa/application/providers/repository_providers.dart';
import 'package:bol_il_bwa/application/providers/user_provider.dart';
import 'package:bol_il_bwa/domain/entities/password_share.dart';

final _myPasswordsProvider = FutureProvider<List<PasswordShare>>((ref) async {
  final userId = ref.read(currentUserIdProvider);
  return ref.read(passwordRepositoryProvider).getPasswordsByUserId(userId);
});

class MyPasswordsScreen extends ConsumerWidget {
  const MyPasswordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPws = ref.watch(_myPasswordsProvider);

    return PointerInterceptor(
      child: Scaffold(
      appBar: AppBar(
        title: const Text('내 비번 공유 기록'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: asyncPws.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text('목록을 불러올 수 없습니다', style: TextStyle(color: Colors.grey[500])),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(_myPasswordsProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (pws) {
          if (pws.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 64, color: Colors.grey[200]),
                  const SizedBox(height: 16),
                  Text('공유한 비밀번호가 없습니다', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
                  const SizedBox(height: 8),
                  Text('잠긴 화장실의 비밀번호를 공유해보세요!',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pws.length,
            itemBuilder: (context, i) => PasswordCard(
              passwordShare: pws[i],
              onLikePressed: null,
            ),
          );
        },
      ),
    ), // Scaffold
    ); // PointerInterceptor
  }
}
