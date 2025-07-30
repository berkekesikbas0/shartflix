import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../movies/domain/entities/movie_entity.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

class UpdateProfilePhotoEvent extends ProfileEvent {
  final String photoUrl;

  const UpdateProfilePhotoEvent(this.photoUrl);

  @override
  List<Object?> get props => [photoUrl];
}

class RefreshProfileEvent extends ProfileEvent {
  const RefreshProfileEvent();
}

class UpdateFavoriteMoviesEvent extends ProfileEvent {
  final List<MovieEntity> favoriteMovies;

  const UpdateFavoriteMoviesEvent(this.favoriteMovies);

  @override
  List<Object?> get props => [favoriteMovies];
}

class UploadProfilePhotoEvent extends ProfileEvent {
  final File photoFile;

  const UploadProfilePhotoEvent(this.photoFile);

  @override
  List<Object?> get props => [photoFile];
}
