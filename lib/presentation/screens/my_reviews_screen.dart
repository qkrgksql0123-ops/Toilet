import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:bol_il_bwa/presentation/theme/app_theme.dart';
import 'package:bol_il_bwa/presentation/widgets/review_card.dart';
import 'package:bol_il_bwa/application/providers/repository_providers.dart';
import 'package:bol_il_bwa/application/providers/user_provider.dart';
import 'package:bol_il_bwa/domain/entities/review.dart';

final _myReviewsProvider = FutureProvider<List<Review>>((ref) async {
  final userId = ref.read(currentUserIdProvider);
  return ref.read(reviewRepositoryProvider).getReviewsByUserId(userId);
});

class MyReviewsScreen extends ConsumerWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncReviews = ref.watch(_myReviewsProvider);

    return PointerInterceptor(
      child: Scaffold(
      appBar: AppBar(
        title: const Text('내 리뷰 기록'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: asyncReviews.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text('리뷰를 불러올 수 없습니다', style: TextStyle(color: Colors.grey[500])),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(_myReviewsProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (reviews) {
          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[200]),
                  const SizedBox(height: 16),
                  Text('아직 작성한 리뷰가 없습니다', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
                  const SizedBox(height: 8),
                  Text('화장실을 방문하고 리뷰를 남겨보세요!',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, i) => ReviewCard(review: reviews[i]),
          );
        },
      ),
    ), // Scaffold
    ); // PointerInterceptor
  }
}
