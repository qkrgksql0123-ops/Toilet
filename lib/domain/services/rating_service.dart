import 'package:bol_il_bwa/domain/entities/review.dart';

class RatingService {
  /// 리뷰 목록에서 평균 평점 계산
  static double calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold<int>(0, (acc, review) => acc + review.rating);
    return sum / reviews.length;
  }

  /// 평점 분포 계산
  static Map<int, int> getRatingDistribution(List<Review> reviews) {
    final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final review in reviews) {
      distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
    }
    return distribution;
  }

  /// 평점을 문자 설명으로 변환
  static String getRatingDescription(int rating) {
    switch (rating) {
      case 1:
        return '매우 불만족';
      case 2:
        return '불만족';
      case 3:
        return '보통';
      case 4:
        return '만족';
      case 5:
        return '매우 만족';
      default:
        return '평점 없음';
    }
  }
}
