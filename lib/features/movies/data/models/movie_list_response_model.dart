import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/movie_list_entity.dart';
import 'movie_model.dart';

part 'movie_list_response_model.g.dart';

/// ServiceLabs API response wrapper
@JsonSerializable()
class ServiceLabsApiResponseModel {
  final Map<String, dynamic>? response;
  final MovieListDataModel? data;

  const ServiceLabsApiResponseModel({this.response, this.data});

  factory ServiceLabsApiResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceLabsApiResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceLabsApiResponseModelToJson(this);

  /// Check if response is successful
  bool get isSuccess => response?['code'] == 200;

  /// Get error message
  String get errorMessage => response?['message'] ?? 'Unknown error';
}

/// Movie list data model for API responses
@JsonSerializable()
class MovieListDataModel {
  final List<MovieModel> movies;
  final PaginationModel? pagination;

  const MovieListDataModel({required this.movies, this.pagination});

  factory MovieListDataModel.fromJson(Map<String, dynamic> json) =>
      _$MovieListDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovieListDataModelToJson(this);
}

/// Pagination model for API responses
@JsonSerializable()
class PaginationModel {
  final int totalCount;
  final int perPage;
  final int maxPage;
  final int currentPage;

  const PaginationModel({
    required this.totalCount,
    required this.perPage,
    required this.maxPage,
    required this.currentPage,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
      _$PaginationModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationModelToJson(this);
}

/// Movie list response model for API responses
@JsonSerializable()
class MovieListResponseModel {
  final List<MovieModel> movies;
  final int totalPages;
  final int currentPage;

  const MovieListResponseModel({
    required this.movies,
    required this.totalPages,
    required this.currentPage,
  });

  /// Convert from ServiceLabs API response
  factory MovieListResponseModel.fromServiceLabsResponse(
    ServiceLabsApiResponseModel apiResponse,
  ) {
    if (!apiResponse.isSuccess || apiResponse.data == null) {
      throw Exception('API Error: ${apiResponse.errorMessage}');
    }

    final data = apiResponse.data!;
    final pagination = data.pagination;

    return MovieListResponseModel(
      movies: data.movies,
      totalPages: pagination?.maxPage ?? 1,
      currentPage: pagination?.currentPage ?? 1,
    );
  }

  /// Convert from JSON
  factory MovieListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MovieListResponseModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$MovieListResponseModelToJson(this);

  /// Convert to domain entity
  MovieListEntity toEntity({List<String> favoriteIds = const []}) {
    final movieEntities =
        movies.map((movie) {
          final isFavorite = favoriteIds.contains(movie.id);
          return movie.toEntity(isFavorite: isFavorite);
        }).toList();

    return MovieListEntity(
      movies: movieEntities,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  @override
  String toString() {
    return 'MovieListResponseModel(movies: ${movies.length}, totalPages: $totalPages, currentPage: $currentPage)';
  }
}
