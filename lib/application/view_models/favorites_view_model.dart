import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bol_il_bwa/domain/entities/toilet.dart';
import 'package:bol_il_bwa/data/repositories/toilet_repository.dart';
import 'package:bol_il_bwa/application/state/toilet_state.dart';
import 'package:bol_il_bwa/application/providers/repository_providers.dart';

class FavoritesViewModel extends StateNotifier<FavoritesState> {
  final ToiletRepository _toiletRepository;
  final Set<String> _favoriteIds = {};

  FavoritesViewModel(this._toiletRepository) : super(const FavoritesState());

  // Toilet 객체까지 넘기면 즉시 반영, 없으면 비동기 로드
  void toggleFavorite(String toiletId, [Toilet? toilet]) {
    if (_favoriteIds.contains(toiletId)) {
      _favoriteIds.remove(toiletId);
      state = state.copyWith(
        favorites: state.favorites.where((t) => t.id != toiletId).toList(),
      );
    } else {
      _favoriteIds.add(toiletId);
      if (toilet != null) {
        // 즉시 반영 (MapScreen에서 호출 시)
        state = state.copyWith(favorites: [...state.favorites, toilet]);
      } else {
        // FavoritesScreen 내부 토글 등 fallback
        _loadFavorites();
      }
    }
  }

  bool isFavorited(String toiletId) => _favoriteIds.contains(toiletId);

  Future<void> _loadFavorites() async {
    state = state.copyWith(isLoading: true);
    try {
      final all = await _toiletRepository.getAllToilets();
      final favs = all.where((t) => _favoriteIds.contains(t.id)).toList();
      state = state.copyWith(favorites: favs, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final favoritesViewModelProvider =
    StateNotifierProvider<FavoritesViewModel, FavoritesState>((ref) {
  return FavoritesViewModel(ref.read(toiletRepositoryProvider));
});
