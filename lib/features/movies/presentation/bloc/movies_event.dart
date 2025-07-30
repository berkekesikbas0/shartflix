import 'package:equatable/equatable.dart';

/// Base movies event
abstract class MoviesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load initial movies (first page)
class LoadMoviesEvent extends MoviesEvent {}

/// Load next page of movies (infinite scroll)
class LoadMoreMoviesEvent extends MoviesEvent {}

/// Refresh movies list (pull-to-refresh)
class RefreshMoviesEvent extends MoviesEvent {}

/// Toggle favorite status of a movie
class ToggleMovieFavoriteEvent extends MoviesEvent {
  final String movieId;
  final bool isFavorite;

  ToggleMovieFavoriteEvent({required this.movieId, required this.isFavorite});

  @override
  List<Object?> get props => [movieId, isFavorite];
}

/// Retry loading after error
class RetryLoadMoviesEvent extends MoviesEvent {}
