import 'package:json_annotation/json_annotation.dart';
import 'movie_model.dart';

part 'favorite_movies_response_model.g.dart';

/// Response wrapper for ServiceLabs favorites API
@JsonSerializable()
class ServiceLabsFavoritesResponseModel {
  final Map<String, dynamic>? response;
  final List<MovieModel> data;

  const ServiceLabsFavoritesResponseModel({this.response, required this.data});

  factory ServiceLabsFavoritesResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$ServiceLabsFavoritesResponseModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ServiceLabsFavoritesResponseModelToJson(this);

  /// Check if response is successful
  bool get isSuccess => response?['code'] == 200;

  /// Get error message
  String get errorMessage => response?['message'] ?? 'Unknown error';
}

/// Response model for favorite movies list
@JsonSerializable()
class FavoriteMoviesResponseModel {
  final List<MovieModel> movies;

  const FavoriteMoviesResponseModel({required this.movies});

  /// Convert from ServiceLabs API response
  factory FavoriteMoviesResponseModel.fromServiceLabsResponse(
    ServiceLabsFavoritesResponseModel apiResponse,
  ) {
    if (!apiResponse.isSuccess) {
      throw Exception('API Error: ${apiResponse.errorMessage}');
    }
    return FavoriteMoviesResponseModel(movies: apiResponse.data);
  }

  factory FavoriteMoviesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FavoriteMoviesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteMoviesResponseModelToJson(this);

  @override
  String toString() => 'FavoriteMoviesResponseModel(movies: ${movies.length})';
}
