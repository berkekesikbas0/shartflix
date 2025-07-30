import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie_list_entity.dart';
import '../repositories/movies_repository.dart';

/// Use case for getting paginated movies
@injectable
class GetMoviesUseCase {
  final MoviesRepository _repository;

  GetMoviesUseCase(this._repository);

  /// Execute the use case
  ///
  /// [page] - Page number to fetch (1-based)
  /// Returns [MovieListEntity] on success or [Failure] on error
  Future<Either<Failure, MovieListEntity>> call({required int page}) async {
    if (page < 1) {
      return const Left(
        ValidationFailure('Page number must be greater than 0'),
      );
    }

    return await _repository.getMovies(page: page);
  }
}
