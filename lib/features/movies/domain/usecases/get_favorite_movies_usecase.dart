import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie_entity.dart';
import '../repositories/movies_repository.dart';

/// Use case for getting user's favorite movies
@injectable
class GetFavoriteMoviesUseCase {
  final MoviesRepository _repository;

  GetFavoriteMoviesUseCase(this._repository);

  /// Execute the use case
  ///
  /// Returns list of favorite movies or [Failure] on error
  Future<Either<Failure, List<MovieEntity>>> call() async {
    return await _repository.getFavoriteMovies();
  }
}
