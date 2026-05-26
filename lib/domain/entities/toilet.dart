class Toilet {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final double avgRating;
  final bool isLocked;

  Toilet({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.avgRating,
    required this.isLocked,
  });

  factory Toilet.fromMap(Map<String, dynamic> map) {
    return Toilet(
      id: map['id'] as String,
      name: map['name'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      address: map['address'] as String,
      avgRating: (map['avgRating'] as num).toDouble(),
      isLocked: map['isLocked'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'avgRating': avgRating,
      'isLocked': isLocked,
    };
  }

  Toilet copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    double? avgRating,
    bool? isLocked,
  }) {
    return Toilet(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      avgRating: avgRating ?? this.avgRating,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  String toString() => 'Toilet(id: $id, name: $name, avgRating: $avgRating)';
}
