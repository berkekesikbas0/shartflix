import 'package:equatable/equatable.dart';
import '../../domain/entities/movie_entity.dart';

/// Base movies state
abstract class MoviesState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state
class MoviesInitial extends MoviesState {}

/// Loading first page of movies
class MoviesLoading extends MoviesState {}

/// Movies loaded successfully
class MoviesLoaded extends MoviesState {
  final List<MovieEntity> movies;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool isLoadingMore;
  final bool isRefreshing;

  MoviesLoaded({
    required this.movies,
    required this.currentPage,
    required this.totalPages,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  }) : hasNextPage = currentPage < totalPages;

  /// Copy state with updated values
  MoviesLoaded copyWith({
    List<MovieEntity>? movies,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return MoviesLoaded(
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    movies,
    currentPage,
    totalPages,
    hasNextPage,
    isLoadingMore,
    isRefreshing,
  ];
}

/// Error loading movies
class MoviesError extends MoviesState {
  final String message;
  final bool canRetry;

  MoviesError({required this.message, this.canRetry = true});

  @override
  List<Object?> get props => [message, canRetry];
}

/// Error loading more movies (infinite scroll error)
class MoviesLoadMoreError extends MoviesLoaded {
  final String errorMessage;

  MoviesLoadMoreError({
    required super.movies,
    required super.currentPage,
    required super.totalPages,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
