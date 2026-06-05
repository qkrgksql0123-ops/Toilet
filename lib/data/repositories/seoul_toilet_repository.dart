import 'package:bol_il_bwa/data/api/public_toilet_api.dart';
import 'package:bol_il_bwa/data/repositories/toilet_repository.dart';
import 'package:bol_il_bwa/domain/entities/toilet.dart';
import 'package:bol_il_bwa/domain/services/distance_service.dart';

class SeoulToiletRepository implements ToiletRepository {
  final PublicToiletApi _api;
  List<Toilet>? _cache;

  SeoulToiletRepository({PublicToiletApi? api})
      : _api = api ?? PublicToiletApi();

  Future<List<Toilet>> _getAll() async {
    if (_cache != null) return _cache!;
    final rows = await _api.fetchAllToilets();
    _cache = rows
        .where((r) => r['COORD_X'] != null && r['COORD_Y'] != null)
        .map(_rowToToilet)
        .toList();
    return _cache!;
  }

  Toilet _rowToToilet(Map<String, dynamic> row) {
    return Toilet(
      id: row['OBJECTID'].toString(),
      name: (row['CONTS_NAME'] as String?)?.isNotEmpty == true
          ? row['CONTS_NAME'] as String
          : '공중화장실',
      latitude: (row['COORD_Y'] as num).toDouble(),
      longitude: (row['COORD_X'] as num).toDouble(),
      address: (row['ADDR_NEW'] as String?)?.isNotEmpty == true
          ? row['ADDR_NEW'] as String
          : (row['ADDR_OLD'] as String?) ?? '',
      avgRating: 0.0,
      isLocked: false,
    );
  }

  @override
  Future<List<Toilet>> getNearbyToilets(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    final all = await _getAll();
    return all
        .where((t) => DistanceService.isWithinRadius(
              latitude,
              longitude,
              t.latitude,
              t.longitude,
              radiusKm,
            ))
        .toList();
  }

  @override
  Future<Toilet?> getToiletById(String toiletId) async {
    final all = await _getAll();
    try {
      return all.firstWhere((t) => t.id == toiletId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Toilet>> getAllToilets() => _getAll();

  @override
  Future<List<Toilet>> searchToilets(String query) async {
    final all = await _getAll();
    final lower = query.toLowerCase();
    return all
        .where((t) =>
            t.name.toLowerCase().contains(lower) ||
            t.address.toLowerCase().contains(lower))
        .toList();
  }
}
