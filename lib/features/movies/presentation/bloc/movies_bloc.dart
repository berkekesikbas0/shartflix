import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/usecases/get_movies_usecase.dart';
import '../../domain/usecases/get_favorite_movies_usecase.dart';
import '../../domain/usecases/toggle_movie_favorite_usecase.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../../core/services/event_bus_service.dart';
import '../../../../core/services/favorite_movies_stream_service.dart';
import 'movies_event.dart';
import 'movies_state.dart';

/// Movies BLoC for managing movie list state
@injectable
class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final GetMoviesUseCase _getMoviesUseCase;
  final GetFavoriteMoviesUseCase _getFavoriteMoviesUseCase;
  final ToggleMovieFavoriteUseCase _toggleMovieFavoriteUseCase;
  final EventBusService _eventBus;
  final FavoriteMoviesStreamService _favoriteMoviesStreamService;
  ProfileBloc? _profileBloc; // Optional reference to Profile BLoC

  // Movies per page as requested in requirements: 5

  MoviesBloc(
    this._getMoviesUseCase,
    this._getFavoriteMoviesUseCase,
    this._toggleMovieFavoriteUseCase,
    this._eventBus,
    this._favoriteMoviesStreamService,
  ) : super(MoviesInitial()) {
    on<LoadMoviesEvent>(_onLoadMovies);
    on<LoadMoreMoviesEvent>(_onLoadMoreMovies);
    on<RefreshMoviesEvent>(_onRefreshMovies);
    on<ToggleMovieFavoriteEvent>(_onToggleMovieFavorite);
    on<RetryLoadMoviesEvent>(_onRetryLoadMovies);
  }

  /// Handle loading initial movies
  Future<void> _onLoadMovies(
    LoadMoviesEvent event,
    Emitter<MoviesState> emit,
  ) async {
    emit(MoviesLoading());

    print('🔄 BLoC: Starting to load movies...');

    print('🔄 BLoC: Loading movies from API...');
    final result = await _getMoviesUseCase(page: 1);

    result.fold((failure) => emit(MoviesError(message: failure.message)), (
      movieList,
    ) {
      print(
        '📊 BLoC: Loaded movies - currentPage: ${movieList.currentPage}, totalPages: ${movieList.totalPages}, hasNextPage: ${movieList.currentPage < movieList.totalPages}',
      );
      emit(
        MoviesLoaded(
          movies: movieList.movies,
          currentPage: movieList.currentPage,
          totalPages: movieList.totalPages,
        ),
      );
    });
  }

  /// Load favorite movies from API and sync local storage
  Future<void> _loadFavoriteMovies() async {
    try {
      print('🔄 BLoC: Loading favorite movies from API...');
      print(
        '🔄 BLoC: _getFavoriteMoviesUseCase is null: ${_getFavoriteMoviesUseCase == null}',
      );

      final result = await _getFavoriteMoviesUseCase();
      result.fold(
        (failure) {
          // If API call fails, continue with local storage
          print(
            '⚠️ BLoC: Failed to load favorites from API: ${failure.message}',
          );
        },
        (favoriteMovies) {
          print(
            '✅ BLoC: Loaded ${favoriteMovies.length} favorite movies from API',
          );
          print(
            '📝 BLoC: Favorite movie IDs: ${favoriteMovies.map((m) => m.id).toList()}',
          );
        },
      );
    } catch (e) {
      print('❌ BLoC: Error loading favorite movies: $e');
      print('❌ BLoC: Error stack trace: ${e.toString()}');
    }
  }

  /// Handle loading more movies (infinite scroll)
  Future<void> _onLoadMoreMovies(
    LoadMoreMoviesEvent event,
    Emitter<MoviesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MoviesLoaded) return;

    // Don't load more if already loading or no more pages
    if (currentState.isLoadingMore || !currentState.hasNextPage) {
      print(
        '⚠️ BLoC: Cannot load more - isLoadingMore: ${currentState.isLoadingMore}, hasNextPage: ${currentState.hasNextPage}',
      );
      return;
    }

    print(
      '🔄 BLoC: Loading more movies - page ${currentState.currentPage + 1}',
    );

    // Set loading more state
    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await _getMoviesUseCase(page: nextPage);

    result.fold(
      (failure) => emit(
        MoviesLoadMoreError(
          movies: currentState.movies,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          errorMessage: failure.message,
        ),
      ),
      (movieList) {
        final updatedMovies = List<MovieEntity>.from(currentState.movies)
          ..addAll(movieList.movies);

        print(
          '✅ BLoC: Loaded ${movieList.movies.length} more movies, total: ${updatedMovies.length}',
        );

        emit(
          MoviesLoaded(
            movies: updatedMovies,
            currentPage: movieList.currentPage,
            totalPages: movieList.totalPages,
            isLoadingMore: false, // Reset loading state
          ),
        );
      },
    );
  }

  /// Handle refreshing movies (pull-to-refresh)
  Future<void> _onRefreshMovies(
    RefreshMoviesEvent event,
    Emitter<MoviesState> emit,
  ) async {
    print('🔄 BLoC: Refreshing movies...');

    final currentState = state;
    if (currentState is MoviesLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    }

    // First reload favorite movies to sync with API
    await _loadFavoriteMovies();

    final result = await _getMoviesUseCase(page: 1);

    result.fold(
      (failure) {
        print('❌ BLoC: Failed to refresh movies: ${failure.message}');
        if (currentState is MoviesLoaded) {
          // Keep existing movies and show error
          emit(currentState.copyWith(isRefreshing: false));
        } else {
          emit(MoviesError(message: failure.message));
        }
      },
      (movieList) {
        print(
          '✅ BLoC: Refreshed movies - loaded ${movieList.movies.length} movies',
        );
        emit(
          MoviesLoaded(
            movies: movieList.movies,
            currentPage: movieList.currentPage,
            totalPages: movieList.totalPages,
          ),
        );
      },
    );
  }

  /// Handle toggling movie favorite status
  Future<void> _onToggleMovieFavorite(
    ToggleMovieFavoriteEvent event,
    Emitter<MoviesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MoviesLoaded) return;

    // Optimistically update UI
    final updatedMovies =
        currentState.movies.map((movie) {
          if (movie.id == event.movieId) {
            return movie.copyWith(isFavorite: event.isFavorite);
          }
          return movie;
        }).toList();

    emit(currentState.copyWith(movies: updatedMovies));

    // Update favorite status in repository
    final result = await _toggleMovieFavoriteUseCase(
      movieId: event.movieId,
      isFavorite: event.isFavorite,
    );

    result.fold(
      (failure) {
        // Revert optimistic update on failure
        final revertedMovies =
            currentState.movies.map((movie) {
              if (movie.id == event.movieId) {
                return movie.copyWith(isFavorite: !event.isFavorite);
              }
              return movie;
            }).toList();

        emit(currentState.copyWith(movies: revertedMovies));
      },
      (updatedMovie) {
        // Success - keep the optimistic update
        // Update Profile BLoC with new favorite movies
        _updateProfileFavoriteMovies(updatedMovies);
        print('🔄 Movies BLoC: Toggle successful, updating Profile BLoC');
        print(
          '🔄 Movies BLoC: Current favorites count: ${updatedMovies.where((m) => m.isFavorite).length}',
        );
      },
    );
  }

  /// Update Profile BLoC with favorite movies
  void _updateProfileFavoriteMovies(List<MovieEntity> movies) {
    final favoriteMovies = movies.where((movie) => movie.isFavorite).toList();
    print('🔄 Movies BLoC: Found ${favoriteMovies.length} favorite movies');

    // Update stream service
    _favoriteMoviesStreamService.updateFavoriteMovies(favoriteMovies);
    print('🔄 Movies BLoC: Updated FavoriteMoviesStreamService');

    // Try direct BLoC communication
    if (_profileBloc != null) {
      _profileBloc!.add(UpdateFavoriteMoviesEvent(favoriteMovies));
      print('🔄 Movies BLoC: Updated Profile BLoC directly');
    }

    // Also emit event bus for global communication
    _eventBus.emit(FavoriteMoviesUpdatedEvent(favoriteMovies));
    print('🔄 Movies BLoC: Emitted FavoriteMoviesUpdatedEvent');
  }

  /// Set Profile BLoC reference
  void setProfileBloc(ProfileBloc profileBloc) {
    _profileBloc = profileBloc;
    print('🔗 Movies BLoC: Profile BLoC reference set');
  }

  /// Handle retry loading movies after error
  Future<void> _onRetryLoadMovies(
    RetryLoadMoviesEvent event,
    Emitter<MoviesState> emit,
  ) async {
    add(LoadMoviesEvent());
  }
}
