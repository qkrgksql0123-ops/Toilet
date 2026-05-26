class PasswordShare {
  final String id;
  final String toiletId;
  final String password;
  final String userId;
  final int likes;
  final DateTime createdAt;

  PasswordShare({
    required this.id,
    required this.toiletId,
    required this.password,
    required this.userId,
    required this.likes,
    required this.createdAt,
  });
}
