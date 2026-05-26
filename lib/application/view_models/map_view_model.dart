import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bol_il_bwa/domain/entities/toilet.dart';
import 'package:bol_il_bwa/data/repositories/toilet_repository.dart';
import 'package:bol_il_bwa/application/state/toilet_state.dart';
import 'package:bol_il_bwa/application/providers/repository_providers.dart';
import 'package:bol_il_bwa/domain/rules/toilet_rules.dart';

class MapViewModel extends StateNotifier<ToiletState> {
  final ToiletRepository _toiletRepository;
  final Set<String> _favorites = {};

  MapViewModel(this._toiletRepository) : super(const ToiletState());

  Future<void> loadNearbyToilets(
    double latitude,
    double longitude,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final toilets = await _toiletRepository.getNearbyToilets(
        latitude,
        longitude,
        ToiletRules.nearbyRadiusKm,
      );
      state = state.copyWith(
        toilets: toilets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadAllToilets() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final toilets = await _toiletRepository.getAllToilets();
      state = state.copyWith(
        toilets: toilets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchToilets(String query) async {
    if (query.isEmpty) {
      await loadAllToilets();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final toilets = await _toiletRepository.searchToilets(query);
      state = state.copyWith(
        toilets: toilets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void toggleFavorite(String toiletId) {
    if (_favorites.contains(toiletId)) {
      _favorites.remove(toiletId);
    } else {
      _favorites.add(toiletId);
    }
  }

  bool isFavorited(String toiletId) {
    return _favorites.contains(toiletId);
  }

  List<Toilet> getFavorites() {
    return state.toilets
        .where((toilet) => _favorites.contains(toilet.id))
        .toList();
  }
}

final mapViewModelProvider =
    StateNotifierProvider<MapViewModel, ToiletState>((ref) {
  return MapViewModel(ref.read(toiletRepositoryProvider));
});
