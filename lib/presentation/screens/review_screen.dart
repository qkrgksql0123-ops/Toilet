import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:bol_il_bwa/presentation/theme/app_theme.dart';
import 'package:bol_il_bwa/presentation/widgets/rating_widget.dart';
import 'package:bol_il_bwa/application/view_models/review_view_model.dart';

class ReviewScreen extends ConsumerWidget {
  final String toiletId;

  const ReviewScreen({
    Key? key,
    required this.toiletId,
  }) : super(key: key);

  void _submitReview(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.read(reviewViewModelProvider.notifier);
    final success = await viewModel.submitReview(toiletId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('리뷰가 등록되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else {
      final state = ref.read(reviewViewModelProvider);
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewViewModelProvider);
    final viewModel = ref.read(reviewViewModelProvider.notifier);

    return PointerInterceptor(
      child: Scaffold(
      appBar: AppBar(
        title: const Text('리뷰 작성'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '별점을 선택해주세요',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: RatingWidget(
                  initialRating: state.selectedRating.toDouble(),
                  readOnly: false,
                  size: 48,
                  onRatingChanged: (rating) {
                    viewModel.setRating(rating);
                  },
                ),
              ),
              if (state.selectedRating > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: Text(
                      _getRatingDescription(state.selectedRating),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              const Text(
                '리뷰 작성',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: viewModel.setComment,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: '화장실의 청결도, 편의시설, 기타 정보를 작성해주세요',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppTheme.surfaceColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppTheme.surfaceColor,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${state.comment.length}/500자',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () => _submitReview(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: state.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '리뷰 등록',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    ), // Scaffold
    ); // PointerInterceptor
  }

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 1:
        return '😞 불만족';
      case 2:
        return '😕 아쉬움';
      case 3:
        return '😐 보통';
      case 4:
        return '😊 만족';
      case 5:
        return '😍 매우 만족';
      default:
        return '';
    }
  }
}
