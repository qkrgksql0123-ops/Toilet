class ToiletRules {
  static const double nearbyRadiusKm = 0.5; // 500m
  static const int maxPasswordLength = 20;
  static const int minPasswordLength = 1;
  static const int minRatingValue = 1;
  static const int maxRatingValue = 5;
  static const int maxCommentLength = 500;
  static const int minCommentLength = 1;

  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength &&
        password.length <= maxPasswordLength;
  }

  static bool isValidRating(int rating) {
    return rating >= minRatingValue && rating <= maxRatingValue;
  }

  static bool isValidComment(String comment) {
    return comment.length >= minCommentLength &&
        comment.length <= maxCommentLength;
  }
}
