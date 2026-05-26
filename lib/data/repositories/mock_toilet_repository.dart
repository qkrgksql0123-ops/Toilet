import 'package:bol_il_bwa/domain/entities/toilet.dart';
import 'package:bol_il_bwa/domain/services/distance_service.dart';
import 'package:bol_il_bwa/data/repositories/toilet_repository.dart';
import 'package:bol_il_bwa/data/mock/mock_data.dart';

class MockToiletRepository implements ToiletRepository {
  @override
  Future<List<Toilet>> getNearbyToilets(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.toilets.where((toilet) {
      return DistanceService.isWithinRadius(
        latitude,
        longitude,
        toilet.latitude,
        toilet.longitude,
        radiusKm,
      );
    }).toList();
  }

  @override
  Future<Toilet?> getToiletById(String toiletId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.getToiletById(toiletId);
  }

  @override
  Future<List<Toilet>> getAllToilets() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.toilets;
  }

  @override
  Future<List<Toilet>> searchToilets(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final lowerQuery = query.toLowerCase();
    return MockData.toilets
        .where((toilet) =>
            toilet.name.toLowerCase().contains(lowerQuery) ||
            toilet.address.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
