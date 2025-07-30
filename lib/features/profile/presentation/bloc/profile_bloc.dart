import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_profile_photo_usecase.dart';
import '../../domain/usecases/upload_profile_photo_usecase.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../../../core/services/event_bus_service.dart';
import '../../../../core/services/favorite_movies_stream_service.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import 'profile_event.dart';
import 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateProfilePhotoUseCase _updateProfilePhotoUseCase;
  final UploadProfilePhotoUseCase _uploadProfilePhotoUseCase;
  final EventBusService _eventBus;
  final FavoriteMoviesStreamService _favoriteMoviesStreamService;

  ProfileBloc(
    this._getUserProfileUseCase,
    this._updateProfilePhotoUseCase,
    this._uploadProfilePhotoUseCase,
    this._eventBus,
    this._favoriteMoviesStreamService,
  ) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfilePhotoEvent>(_onUpdateProfilePhoto);
    on<RefreshProfileEvent>(_onRefreshProfile);
    on<UpdateFavoriteMoviesEvent>(_onUpdateFavoriteMovies);
    on<UploadProfilePhotoEvent>(_onUploadProfilePhoto);

    // Listen to global favorite movies updates
    _eventBus.on<FavoriteMoviesUpdatedEvent>().listen((event) {
      print(
        '🔄 Profile BLoC: Received FavoriteMoviesUpdatedEvent from EventBus',
      );
      // Convert dynamic list to MovieEntity list
      final movieEntities =
          event.favoriteMovies.map((movie) {
            if (movie is Map<String, dynamic>) {
              return MovieEntity(
                id: movie['id'] as String,
                title: movie['title'] as String,
                description: movie['description'] as String? ?? '',
                posterUrl: movie['posterUrl'] as String,
                isFavorite: true,
              );
            }
            return movie as MovieEntity;
          }).toList();
      add(UpdateFavoriteMoviesEvent(movieEntities));
    });

    // Listen to stream service updates
    _favoriteMoviesStreamService.favoriteMoviesStream.listen((favoriteMovies) {
      print(
        '🔄 Profile BLoC: Received stream update with ${favoriteMovies.length} movies',
      );
      add(UpdateFavoriteMoviesEvent(favoriteMovies));
    });
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await _getUserProfileUseCase();

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  Future<void> _onUpdateProfilePhoto(
    UpdateProfilePhotoEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    final result = await _updateProfilePhotoUseCase(event.photoUrl);

    result.fold((failure) => emit(ProfileError(failure.message)), (_) {
      // Update the profile with new photo URL
      final updatedProfile = currentState.profile.copyWith(
        profilePhotoUrl: event.photoUrl,
      );
      emit(ProfileLoaded(profile: updatedProfile));
    });
  }

  Future<void> _onRefreshProfile(
    RefreshProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    }

    final result = await _getUserProfileUseCase();

    result.fold((failure) {
      if (currentState is ProfileLoaded) {
        emit(currentState.copyWith(isRefreshing: false));
      } else {
        emit(ProfileError(failure.message));
      }
    }, (profile) => emit(ProfileLoaded(profile: profile)));
  }

  Future<void> _onUploadProfilePhoto(
    UploadProfilePhotoEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    // Set uploading state
    emit(currentState.copyWith(isUploadingPhoto: true));

    final result = await _uploadProfilePhotoUseCase(event.photoFile);

    result.fold(
      (failure) {
        emit(PhotoUploadError(failure.message));
        // Revert back to previous state
        emit(currentState);
      },
      (photoUrl) async {
        print('📸 Photo uploaded successfully with URL: $photoUrl');

        // Update the profile with new photo URL
        final updatedProfile = currentState.profile.copyWith(
          profilePhotoUrl: photoUrl,
        );

        // First update locally
        emit(ProfileLoaded(profile: updatedProfile, isUploadingPhoto: false));

        // Then force refresh from server
        await Future.delayed(const Duration(milliseconds: 500));
        print('🔄 Refreshing profile from server after photo upload...');

        // Get fresh profile data from server
        final profileResult = await _getUserProfileUseCase();
        profileResult.fold(
          (failure) {
            print(
              '⚠️ Failed to refresh profile after upload: ${failure.message}',
            );
          },
          (freshProfile) {
            print(
              '✅ Profile refreshed from server: ${freshProfile.profilePhotoUrl}',
            );
            // Only update if the profile photo URL is not empty
            if (freshProfile.profilePhotoUrl != null &&
                freshProfile.profilePhotoUrl!.isNotEmpty) {
              emit(
                ProfileLoaded(profile: freshProfile, isUploadingPhoto: false),
              );
            }
          },
        );
      },
    );
  }

  void _onUpdateFavoriteMovies(
    UpdateFavoriteMoviesEvent event,
    Emitter<ProfileState> emit,
  ) {
    print(
      '🔄 Profile BLoC: Received UpdateFavoriteMoviesEvent with ${event.favoriteMovies.length} movies',
    );

    final currentState = state;
    if (currentState is ProfileLoaded) {
      // Convert MovieEntity list to FavoriteMovieEntity list
      final favoriteMovies =
          event.favoriteMovies.map((movie) {
            return FavoriteMovieEntity(
              id: movie.id,
              title: movie.title,
              productionCompany:
                  null, // MovieEntity doesn't have productionCompany
              posterUrl: movie.posterUrl,
            );
          }).toList();

      print(
        '🔄 Profile BLoC: Converted to ${favoriteMovies.length} FavoriteMovieEntity',
      );

      final updatedProfile = currentState.profile.copyWith(
        favoriteMovies: favoriteMovies,
      );
      emit(ProfileLoaded(profile: updatedProfile));
      print('✅ Profile BLoC: Updated profile with new favorite movies');
    } else {
      print('⚠️ Profile BLoC: Current state is not ProfileLoaded');
    }
  }
}
