import 'package:bol_il_bwa/domain/entities/toilet.dart';

abstract class ToiletRepository {
  Future<List<Toilet>> getNearbyToilets(
    double latitude,
    double longitude,
    double radiusKm,
  );

  Future<Toilet?> getToiletById(String toiletId);

  Future<List<Toilet>> getAllToilets();

  Future<List<Toilet>> searchToilets(String query);
}
