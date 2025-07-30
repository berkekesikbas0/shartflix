import 'package:equatable/equatable.dart';
import 'movie_entity.dart';

/// Movie list entity representing paginated movie list response
class MovieListEntity extends Equatable {
  final List<MovieEntity> movies;
  final int totalPages;
  final int currentPage;
  final bool hasNextPage;

  const MovieListEntity({
    required this.movies,
    required this.totalPages,
    required this.currentPage,
  }) : hasNextPage = currentPage < totalPages;

  /// Copy entity with updated values
  MovieListEntity copyWith({
    List<MovieEntity>? movies,
    int? totalPages,
    int? currentPage,
  }) {
    return MovieListEntity(
      movies: movies ?? this.movies,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [movies, totalPages, currentPage, hasNextPage];

  @override
  String toString() {
    return 'MovieListEntity(movies: ${movies.length}, totalPages: $totalPages, currentPage: $currentPage, hasNextPage: $hasNextPage)';
  }
}
