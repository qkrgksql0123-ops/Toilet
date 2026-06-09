class Toilet {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final double avgRating;
  final bool isLocked;
  final String? openTime;
  final String? closeTime;
  final bool hasDisabled;
  final bool hasMale;
  final bool hasFemale;

  Toilet({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.avgRating,
    required this.isLocked,
    this.openTime,
    this.closeTime,
    this.hasDisabled = false,
    this.hasMale = true,
    this.hasFemale = true,
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
      openTime: map['openTime'] as String?,
      closeTime: map['closeTime'] as String?,
      hasDisabled: map['hasDisabled'] as bool? ?? false,
      hasMale: map['hasMale'] as bool? ?? true,
      hasFemale: map['hasFemale'] as bool? ?? true,
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
      'openTime': openTime,
      'closeTime': closeTime,
      'hasDisabled': hasDisabled,
      'hasMale': hasMale,
      'hasFemale': hasFemale,
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
    String? openTime,
    String? closeTime,
    bool? hasDisabled,
    bool? hasMale,
    bool? hasFemale,
  }) {
    return Toilet(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      avgRating: avgRating ?? this.avgRating,
      isLocked: isLocked ?? this.isLocked,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      hasDisabled: hasDisabled ?? this.hasDisabled,
      hasMale: hasMale ?? this.hasMale,
      hasFemale: hasFemale ?? this.hasFemale,
    );
  }

  @override
  String toString() => 'Toilet(id: $id, name: $name, avgRating: $avgRating)';
}
