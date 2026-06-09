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

class ReviewScreenState {
  final int selectedRating;
  final String comment;
  final bool isSubmitting;
  final String? error;

  const ReviewScreenState({
    this.selectedRating = 0,
    this.comment = '',
    this.isSubmitting = false,
    this.error,
  });

  ReviewScreenState copyWith({
    int? selectedRating,
    String? comment,
    bool? isSubmitting,
    String? error,
  }) {
    return ReviewScreenState(
      selectedRating: selectedRating ?? this.selectedRating,
      comment: comment ?? this.comment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
    );
  }
}

class PasswordScreenState {
  final String? selectedToiletId;
  final String password;
  final List<Toilet> lockedToilets;
  final bool isSubmitting;
  final String? error;

  const PasswordScreenState({
    this.selectedToiletId,
    this.password = '',
    this.lockedToilets = const [],
    this.isSubmitting = false,
    this.error,
  });

  PasswordScreenState copyWith({
    String? selectedToiletId,
    String? password,
    List<Toilet>? lockedToilets,
    bool? isSubmitting,
    String? error,
  }) {
    return PasswordScreenState(
      selectedToiletId: selectedToiletId ?? this.selectedToiletId,
      password: password ?? this.password,
      lockedToilets: lockedToilets ?? this.lockedToilets,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
    );
  }
}
