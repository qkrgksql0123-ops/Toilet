import 'package:bol_il_bwa/domain/entities/toilet.dart';
import 'package:bol_il_bwa/domain/entities/review.dart';
import 'package:bol_il_bwa/domain/entities/password_share.dart';

class ToiletState {
  final List<Toilet> toilets;
  final bool isLoading;
  final String? error;

  const ToiletState({
    this.toilets = const [],
    this.isLoading = false,
    this.error,
  });

  ToiletState copyWith({
    List<Toilet>? toilets,
    bool? isLoading,
    String? error,
  }) {
    return ToiletState(
      toilets: toilets ?? this.toilets,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ToiletDetailState {
  final Toilet? toilet;
  final List<Review> reviews;
  final List<PasswordShare> passwords;
  final bool isLoading;
  final String? error;

  const ToiletDetailState({
    this.toilet,
    this.reviews = const [],
    this.passwords = const [],
    this.isLoading = false,
    this.error,
  });

  ToiletDetailState copyWith({
    Toilet? toilet,
    List<Review>? reviews,
    List<PasswordShare>? passwords,
    bool? isLoading,
    String? error,
  }) {
    return ToiletDetailState(
      toilet: toilet ?? this.toilet,
      reviews: reviews ?? this.reviews,
      passwords: passwords ?? this.passwords,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class FavoritesState {
  final List<Toilet> favorites;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<Toilet>? favorites,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
