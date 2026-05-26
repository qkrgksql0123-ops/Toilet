import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bol_il_bwa/presentation/theme/app_theme.dart';
import 'package:bol_il_bwa/application/view_models/toilet_view_model.dart';
import 'package:bol_il_bwa/presentation/widgets/rating_widget.dart';
import 'package:bol_il_bwa/presentation/widgets/review_card.dart';
import 'package:bol_il_bwa/presentation/widgets/password_card.dart';

class ToiletDetailScreen extends ConsumerWidget {
  final String toiletId;

  const ToiletDetailScreen({
    super.key,
    required this.toiletId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(toiletViewModelProvider);
    final viewModel = ref.read(toiletViewModelProvider.notifier);

    // 초기 로드
    ref.listen(toiletViewModelProvider, (previous, next) {
      if (previous == null && next.toilet == null && !next.isLoading) {
        Future.microtask(() => viewModel.loadToiletDetail(toiletId));
      }
    });

    if (state.toilet == null && state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('로딩 중...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final toilet = state.toilet;
    if (toilet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('화장실')),
        body: const Center(child: Text('화장실 정보를 불러올 수 없습니다')),
      );
    }

    final passwords = state.passwords;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(toilet.name),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.wc,
                    size: 48,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(toilet),
                    const SizedBox(height: 24),
                    _buildReviewSection(state.reviews),
                    const SizedBox(height: 24),
                    if (toilet.isLocked) _buildPasswordSection(passwords, viewModel),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            '/review',
            arguments: toiletId,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoCard(dynamic toilet) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.surfaceColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  toilet.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (toilet.isLocked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '🔒 잠금',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                RatingWidget(
                  initialRating: toilet.avgRating,
                  readOnly: true,
                ),
                const SizedBox(width: 8),
                Text(
                  '${toilet.avgRating.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    toilet.address,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 8),
                Text(
                  '좌표: ${toilet.latitude.toStringAsFixed(4)}, ${toilet.longitude.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection(dynamic reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '리뷰',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${reviews.length}개',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: Text(
                '리뷰가 없습니다',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ...reviews.map((review) {
            return ReviewCard(review: review);
          }),
      ],
    );
  }

  Widget _buildPasswordSection(List<dynamic> passwords, dynamic viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '공유된 비밀번호',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (passwords.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                '공유된 비밀번호가 없습니다',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ...passwords.map((pw) {
            return PasswordCard(
              passwordShare: pw,
              onLikePressed: () {
                viewModel.likePassword(pw.id);
              },
            );
          }),
      ],
    );
  }
}
