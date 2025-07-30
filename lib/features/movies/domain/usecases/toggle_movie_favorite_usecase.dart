import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie_entity.dart';
import '../repositories/movies_repository.dart';

/// Use case for toggling movie favorite status
@injectable
class ToggleMovieFavoriteUseCase {
  final MoviesRepository _repository;

  ToggleMovieFavoriteUseCase(this._repository);

  /// Execute the use case
  ///
  /// [movieId] - ID of the movie to toggle
  /// [isFavorite] - New favorite status
  /// Returns [MovieEntity] with updated favorite status or [Failure] on error
  Future<Either<Failure, MovieEntity>> call({
    required String movieId,
    required bool isFavorite,
  }) async {
    if (movieId.isEmpty) {
      return const Left(ValidationFailure('Movie ID cannot be empty'));
    }

    return await _repository.toggleMovieFavorite(
      movieId: movieId,
      isFavorite: isFavorite,
    );
  }
}
