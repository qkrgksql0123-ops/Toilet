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

  factory PasswordShare.fromMap(Map<String, dynamic> map) {
    return PasswordShare(
      id: map['id'] as String,
      toiletId: map['toiletId'] as String,
      password: map['password'] as String,
      userId: map['userId'] as String,
      likes: map['likes'] as int,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'toiletId': toiletId,
      'password': password,
      'userId': userId,
      'likes': likes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PasswordShare copyWith({
    String? id,
    String? toiletId,
    String? password,
    String? userId,
    int? likes,
    DateTime? createdAt,
  }) {
    return PasswordShare(
      id: id ?? this.id,
      toiletId: toiletId ?? this.toiletId,
      password: password ?? this.password,
      userId: userId ?? this.userId,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'PasswordShare(id: $id, likes: $likes)';
}
