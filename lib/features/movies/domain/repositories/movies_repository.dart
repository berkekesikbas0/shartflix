import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie_entity.dart';
import '../entities/movie_list_entity.dart';

/// Movies repository interface defining contracts for movie operations
abstract class MoviesRepository {
  /// Get paginated list of movies
  ///
  /// [page] - Page number to fetch (1-based)
  /// Returns [MovieListEntity] on success or [Failure] on error
  Future<Either<Failure, MovieListEntity>> getMovies({required int page});

  /// Get user's favorite movies from API
  ///
  /// Returns list of favorite movies or [Failure] on error
  Future<Either<Failure, List<MovieEntity>>> getFavoriteMovies();

  /// Toggle favorite status of a movie locally
  ///
  /// [movieId] - ID of the movie to toggle
  /// [isFavorite] - New favorite status
  /// Returns [MovieEntity] with updated favorite status or [Failure] on error
  Future<Either<Failure, MovieEntity>> toggleMovieFavorite({
    required String movieId,
    required bool isFavorite,
  });

  /// Get list of favorite movie IDs from local storage
  ///
  /// Returns list of favorite movie IDs or [Failure] on error
  Future<Either<Failure, List<String>>> getFavoriteMovieIds();

  /// Save favorite movie IDs to local storage
  ///
  /// [favoriteIds] - List of favorite movie IDs to save
  /// Returns [Unit] on success or [Failure] on error
  Future<Either<Failure, Unit>> saveFavoriteMovieIds(List<String> favoriteIds);
}
