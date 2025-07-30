import 'dart:async';
import 'package:injectable/injectable.dart';
import '../../features/movies/domain/entities/movie_entity.dart';

/// Stream-based service for real-time favorite movies updates
@singleton
class FavoriteMoviesStreamService {
  final StreamController<List<MovieEntity>> _favoriteMoviesController =
      StreamController<List<MovieEntity>>.broadcast();

  /// Stream of favorite movies updates
  Stream<List<MovieEntity>> get favoriteMoviesStream =>
      _favoriteMoviesController.stream;

  /// Current favorite movies
  List<MovieEntity> _currentFavorites = [];

  /// Get current favorite movies
  List<MovieEntity> get currentFavorites =>
      List.unmodifiable(_currentFavorites);

  /// Update favorite movies and notify all listeners
  void updateFavoriteMovies(List<MovieEntity> favoriteMovies) {
    print(
      '🔄 FavoriteMoviesStreamService: Updating with ${favoriteMovies.length} favorites',
    );
    _currentFavorites = List.from(favoriteMovies);
    _favoriteMoviesController.add(_currentFavorites);
    print(
      '✅ FavoriteMoviesStreamService: Notified ${_favoriteMoviesController.stream.length} listeners',
    );
  }

  /// Add a movie to favorites
  void addToFavorites(MovieEntity movie) {
    if (!_currentFavorites.any((m) => m.id == movie.id)) {
      _currentFavorites.add(movie);
      _favoriteMoviesController.add(_currentFavorites);
      print(
        '✅ FavoriteMoviesStreamService: Added movie ${movie.title} to favorites',
      );
    }
  }

  /// Remove a movie from favorites
  void removeFromFavorites(String movieId) {
    _currentFavorites.removeWhere((movie) => movie.id == movieId);
    _favoriteMoviesController.add(_currentFavorites);
    print(
      '✅ FavoriteMoviesStreamService: Removed movie $movieId from favorites',
    );
  }

  /// Toggle movie favorite status
  void toggleFavorite(MovieEntity movie, bool isFavorite) {
    if (isFavorite) {
      addToFavorites(movie);
    } else {
      removeFromFavorites(movie.id);
    }
  }

  void dispose() {
    _favoriteMoviesController.close();
  }
}
