import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:bol_il_bwa/presentation/theme/app_theme.dart';
import 'package:bol_il_bwa/application/view_models/toilet_view_model.dart';
import 'package:bol_il_bwa/presentation/widgets/review_card.dart';
import 'package:bol_il_bwa/presentation/widgets/password_card.dart';

class ToiletDetailScreen extends ConsumerStatefulWidget {
  final String toiletId;
  const ToiletDetailScreen({super.key, required this.toiletId});

  @override
  ConsumerState<ToiletDetailScreen> createState() => _ToiletDetailScreenState();
}

class _ToiletDetailScreenState extends ConsumerState<ToiletDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(toiletViewModelProvider.notifier).loadToiletDetail(widget.toiletId);
    });
  }

  String _cleanlinessLabel(double rating) {
    if (rating == 0) return '평가 없음';
    if (rating >= 4.5) return '매우 청결 😍';
    if (rating >= 3.5) return '청결 😊';
    if (rating >= 2.5) return '보통 😐';
    if (rating >= 1.5) return '불청결 😕';
    return '매우 불청결 😞';
  }

  Color _cleanlinessColor(double rating) {
    if (rating >= 4.0) return AppTheme.successColor;
    if (rating >= 3.0) return const Color(0xFFF59E0B);
    return AppTheme.errorColor;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(toiletViewModelProvider);

    if (state.isLoading && state.toilet == null) {
      return PointerInterceptor(
        child: Scaffold(
          appBar: AppBar(title: const Text('불러오는 중...')),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final toilet = state.toilet;
    if (toilet == null) {
      return PointerInterceptor(
        child: Scaffold(
          appBar: AppBar(title: const Text('화장실')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                const Text('화장실 정보를 불러올 수 없습니다'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(toiletViewModelProvider.notifier).loadToiletDetail(widget.toiletId),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final reviews = state.reviews;
    final passwords = state.passwords;

    return PointerInterceptor(
      child: Scaffold(
      body: CustomScrollView(
        slivers: [
          // 헤더
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
              title: Text(
                toilet.name,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Icon(
                        toilet.isLocked ? Icons.lock_rounded : Icons.wc_rounded,
                        size: 52,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 기본 정보 카드
                  _InfoCard(toilet: toilet),
                  const SizedBox(height: 16),

                  // 청결도 카드
                  _CleanlinessCard(
                    avgRating: toilet.avgRating,
                    reviewCount: reviews.length,
                    label: _cleanlinessLabel(toilet.avgRating),
                    color: _cleanlinessColor(toilet.avgRating),
                  ),
                  const SizedBox(height: 24),

                  // 리뷰 섹션
                  _SectionHeader(
                    icon: Icons.rate_review_rounded,
                    title: '리뷰',
                    count: reviews.length,
                    onAction: () => Navigator.of(context).pushNamed('/review', arguments: widget.toiletId),
                    actionLabel: '작성',
                  ),
                  const SizedBox(height: 12),
                  if (state.isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                  else if (reviews.isEmpty)
                    _EmptyState(icon: Icons.rate_review_outlined, message: '첫 번째 리뷰를 남겨보세요!')
                  else
                    ...reviews.map((r) => ReviewCard(review: r)),

                  const SizedBox(height: 24),

                  // 비번 섹션 (잠긴 화장실)
                  _SectionHeader(
                    icon: Icons.lock_rounded,
                    title: '비밀번호 공유',
                    count: passwords.length,
                    onAction: () => _showPasswordDialog(context, ref, widget.toiletId),
                    actionLabel: '공유',
                    color: toilet.isLocked ? AppTheme.lockedColor : AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(height: 12),
                  if (!toilet.isLocked)
                    _EmptyState(icon: Icons.lock_open_rounded, message: '잠금이 없는 화장실입니다')
                  else if (passwords.isEmpty)
                    _EmptyState(icon: Icons.lock_rounded, message: '공유된 비밀번호가 없습니다\n알고 있다면 공유해주세요!')
                  else
                    ...passwords.map((pw) => PasswordCard(
                          passwordShare: pw,
                          onLikePressed: () => ref.read(toiletViewModelProvider.notifier).likePassword(pw.id),
                        )),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/review', arguments: widget.toiletId),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        label: const Text('리뷰 작성', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    ), // Scaffold
    ); // PointerInterceptor
  }

  void _showPasswordDialog(BuildContext context, WidgetRef ref, String toiletId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => PointerInterceptor(
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('비밀번호 공유', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '예: 1234',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.lock_rounded),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isEmpty) return;
                Navigator.pop(ctx);
                await ref.read(toiletViewModelProvider.notifier).addPassword(toiletId, controller.text);
                await ref.read(toiletViewModelProvider.notifier).loadToiletDetail(toiletId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('비밀번호가 공유되었습니다 ✓')),
                  );
                }
              },
              child: const Text('공유'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final dynamic toilet;
  const _InfoCard({required this.toilet});

  String _buildHoursText(String? open, String? close) {
    if (open == null && close == null) return '운영시간 정보 없음';
    if (open == '00:00' && (close == '24:00' || close == '00:00')) return '24시간 운영';
    return '${open ?? '-'} ~ ${close ?? '-'}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _InfoRow(icon: Icons.location_on_rounded, text: toilet.address, color: AppTheme.primaryColor),
          if (toilet.openTime != null || toilet.closeTime != null) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.access_time_rounded,
              text: _buildHoursText(toilet.openTime, toilet.closeTime),
              color: AppTheme.textSecondaryColor,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 28),
              _FeatureChip(label: '남성', available: toilet.hasMale),
              const SizedBox(width: 6),
              _FeatureChip(label: '여성', available: toilet.hasFemale),
              const SizedBox(width: 6),
              _FeatureChip(label: '장애인', available: toilet.hasDisabled),
            ],
          ),
          if (toilet.isLocked) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.lock_rounded,
              text: '잠금 화장실 — 비밀번호가 필요합니다',
              color: AppTheme.lockedColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _InfoRow({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimaryColor))),
      ],
    );
  }
}

class _CleanlinessCard extends StatelessWidget {
  final double avgRating;
  final int reviewCount;
  final String label;
  final Color color;
  const _CleanlinessCard({required this.avgRating, required this.reviewCount, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('청결도', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 22,
                    color: const Color(0xFFFB8C00),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 2),
                Text(
                  avgRating == 0 ? '아직 평가가 없어요' : '${avgRating.toStringAsFixed(1)}점 · 리뷰 $reviewCount개',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final VoidCallback onAction;
  final String actionLabel;
  final Color? color;
  const _SectionHeader({
    required this.icon, required this.title, required this.count,
    required this.onAction, required this.actionLabel, this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primaryColor;
    return Row(
      children: [
        Icon(icon, size: 18, color: c),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor)),
        if (count > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('$count', style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.bold)),
          ),
        ],
        const Spacer(),
        GestureDetector(
          onTap: onAction,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(20)),
            child: Text(actionLabel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  final bool available;
  const _FeatureChip({required this.label, required this.available});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: available ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: available ? AppTheme.primaryColor.withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: available ? AppTheme.primaryColor : Colors.grey[400],
        ),
      ),
    );
  }
}
