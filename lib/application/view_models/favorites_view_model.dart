import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bol_il_bwa/data/repositories/toilet_repository.dart';
import 'package:bol_il_bwa/application/state/toilet_state.dart';
import 'package:bol_il_bwa/application/providers/repository_providers.dart';

class FavoritesViewModel extends StateNotifier<FavoritesState> {
  final ToiletRepository _toiletRepository;
  final Set<String> _favorites = {};

  FavoritesViewModel(this._toiletRepository) : super(const FavoritesState());

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final allToilets = await _toiletRepository.getAllToilets();
      final favoriteToilets = allToilets
          .where((toilet) => _favorites.contains(toilet.id))
          .toList();

      state = state.copyWith(
        favorites: favoriteToilets,
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
      state = state.copyWith(
        favorites: state.favorites
            .where((toilet) => toilet.id != toiletId)
            .toList(),
      );
    } else {
      _favorites.add(toiletId);
    }
  }

  bool isFavorited(String toiletId) {
    return _favorites.contains(toiletId);
  }

  void setFavorites(Set<String> favorites) {
    _favorites.clear();
    _favorites.addAll(favorites);
  }
}

final favoritesViewModelProvider =
    StateNotifierProvider<FavoritesViewModel, FavoritesState>((ref) {
  return FavoritesViewModel(ref.read(toiletRepositoryProvider));
});
