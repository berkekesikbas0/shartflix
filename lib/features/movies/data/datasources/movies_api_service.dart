import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/movie_list_response_model.dart';
import '../models/favorite_response_model.dart';
import '../models/favorite_movies_response_model.dart';

part 'movies_api_service.g.dart';

/// Movies API service using Retrofit
@RestApi()
abstract class MoviesApiService {
  factory MoviesApiService(Dio dio) = _MoviesApiService;

  /// Get paginated list of movies
  ///
  /// [page] - Page number (1-based)
  /// [limit] - Number of movies per page
  @GET('/movie/list')
  Future<ServiceLabsApiResponseModel> getMovies({
    @Query('page') required int page,
    @Query('limit') int? limit,
  });

  /// Get user's favorite movies
  @GET('/movie/favorites')
  Future<ServiceLabsFavoritesResponseModel> getFavoriteMovies();

  /// Toggle movie favorite status
  ///
  /// [movieId] - ID of the movie to favorite/unfavorite
  @POST('/movie/favorite/{movieId}')
  Future<ServiceLabsFavoriteResponseModel> toggleMovieFavorite(
    @Path('movieId') String movieId,
  );
}
