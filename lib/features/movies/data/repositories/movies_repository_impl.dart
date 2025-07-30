import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/storage_strategy.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/entities/movie_list_entity.dart';
import '../../domain/repositories/movies_repository.dart';
import '../datasources/movies_api_service.dart';
import '../models/movie_list_response_model.dart';
import '../models/favorite_response_model.dart';
import '../models/favorite_movies_response_model.dart';

/// Movies repository implementation
@LazySingleton(as: MoviesRepository)
class MoviesRepositoryImpl implements MoviesRepository {
  final MoviesApiService _apiService;
  final StorageManager _storageManager;

  static const String _favoriteMoviesKey = 'favorite_movies';

  MoviesRepositoryImpl(this._apiService, this._storageManager);

  @override
  Future<Either<Failure, MovieListEntity>> getMovies({
    required int page,
  }) async {
    try {
      // First, try to get favorite movies from API to sync local storage
      List<String> favoriteIds = [];
      try {
        final favoriteMoviesResult = await getFavoriteMovies();
        favoriteIds = favoriteMoviesResult.fold(
          (failure) {
            print(
              '⚠️ Repository: Failed to get favorites from API: ${failure.message}',
            );
            return <String>[];
          },
          (favoriteMovies) {
            final ids = favoriteMovies.map((m) => m.id).toList();
            print('✅ Repository: Got ${ids.length} favorite IDs from API');
            return ids;
          },
        );
      } catch (e) {
        print('❌ Repository: Error getting favorites from API: $e');
        // Fallback to local storage
        final favoriteResult = await getFavoriteMovieIds();
        favoriteIds = favoriteResult.fold(
          (failure) => <String>[],
          (ids) => ids,
        );
      }

      print(
        '🎬 Repository: Loading movies with ${favoriteIds.length} favorite IDs',
      );

      // Fetch movies from API with page size limit
      final apiResponse = await _apiService.getMovies(
        page: page,
        limit: AppConstants.defaultPageSize,
      );

      // Convert ServiceLabs API response to our model
      final response = MovieListResponseModel.fromServiceLabsResponse(
        apiResponse,
      );

      // Convert to entity with favorite status
      final entity = response.toEntity(favoriteIds: favoriteIds);

      print(
        '✅ Repository: Loaded ${entity.movies.length} movies, ${entity.movies.where((m) => m.isFavorite).length} are favorites',
      );

      return Right(entity);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> getFavoriteMovies() async {
    try {
      // Fetch favorite movies from API
      final apiResponse = await _apiService.getFavoriteMovies();

      // Convert ServiceLabs API response to our model
      final response = FavoriteMoviesResponseModel.fromServiceLabsResponse(
        apiResponse,
      );

      // Convert to entities
      final movieEntities =
          response.movies
              .map((movie) => movie.toEntity(isFavorite: true))
              .toList();

      // Update local storage with favorite IDs
      final favoriteIds = movieEntities.map((movie) => movie.id).toList();
      await saveFavoriteMovieIds(favoriteIds);

      return Right(movieEntities);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to get favorite movies: $e'));
    }
  }

  @override
  Future<Either<Failure, MovieEntity>> toggleMovieFavorite({
    required String movieId,
    required bool isFavorite,
  }) async {
    try {
      print(
        '🔄 Repository: Starting toggle favorite for movieId: $movieId, isFavorite: $isFavorite',
      );

      // Call API to toggle favorite status
      final apiResponse = await _apiService.toggleMovieFavorite(movieId);
      print('✅ Repository: API call successful');

      // Convert ServiceLabs API response to our model
      final response = FavoriteResponseModel.fromServiceLabsResponse(
        apiResponse,
      );
      print('✅ Repository: Response converted, success: ${response.success}');

      if (!response.success) {
        print('❌ Repository: API response indicates failure');
        return Left(
          ServerFailure('Failed to toggle favorite: ${response.message}'),
        );
      }

      // Update local favorite IDs after successful API call
      final favoriteResult = await getFavoriteMovieIds();
      final favoriteIds = favoriteResult.fold(
        (failure) {
          print('❌ Repository: Failed to get favorite IDs: ${failure.message}');
          return <String>[];
        },
        (ids) {
          print('✅ Repository: Got ${ids.length} favorite IDs');
          return ids;
        },
      );

      final updatedIds = List<String>.from(favoriteIds);
      if (isFavorite) {
        if (!updatedIds.contains(movieId)) {
          updatedIds.add(movieId);
          print('➕ Repository: Added movieId to favorites');
        }
      } else {
        updatedIds.remove(movieId);
        print('➖ Repository: Removed movieId from favorites');
      }

      // Save updated favorite IDs locally
      final saveResult = await saveFavoriteMovieIds(updatedIds);
      saveResult.fold(
        (failure) {
          print('❌ Repository: Failed to save favorites: ${failure.message}');
        },
        (_) {
          print(
            '✅ Repository: Successfully saved ${updatedIds.length} favorites',
          );
        },
      );

      // Create movie entity with updated favorite status
      final movieEntity = MovieEntity(
        id: movieId,
        title: '', // These would come from cache or be passed as parameters
        description: '',
        posterUrl: '',
        isFavorite: isFavorite,
      );
      return Right(movieEntity);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to toggle movie favorite: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFavoriteMovieIds() async {
    try {
      final favoriteIds = await _storageManager.retrieve<List<String>>(
        _favoriteMoviesKey,
      );
      return Right(favoriteIds ?? []);
    } catch (e) {
      return Left(CacheFailure('Failed to get favorite movie IDs: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveFavoriteMovieIds(
    List<String> favoriteIds,
  ) async {
    try {
      await _storageManager.store(_favoriteMoviesKey, favoriteIds);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to save favorite movie IDs: $e'));
    }
  }

  /// Handle Dio exceptions and convert to appropriate failures
  Failure _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'No internet connection. Please check your connection and try again.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Something went wrong';

        switch (statusCode) {
          case 400:
            return ServerFailure('Bad request: $message', 400);
          case 401:
            return AuthFailure('Unauthorized: $message', 401);
          case 403:
            return AuthFailure('Forbidden: $message', 403);
          case 404:
            return ServerFailure('Not found: $message', 404);
          case 500:
            return ServerFailure('Internal server error: $message', 500);
          default:
            return ServerFailure('Server error: $message', statusCode);
        }

      case DioExceptionType.cancel:
        return const NetworkFailure('Request was cancelled');

      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          'Bad certificate. Please check your connection.',
        );

      case DioExceptionType.unknown:
        return UnknownFailure('An unknown error occurred: ${e.message}');
    }
  }
}
