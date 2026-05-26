import 'dart:math';

class DistanceService {
  static const double earthRadiusKm = 6371.0;

  /// Haversine 공식으로 두 지점 간 거리 계산 (km)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRad(double degree) => degree * pi / 180.0;

  /// 두 좌표가 특정 반경 내에 있는지 확인 (km)
  static bool isWithinRadius(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double radiusKm,
  ) {
    return calculateDistance(lat1, lon1, lat2, lon2) <= radiusKm;
  }
}
