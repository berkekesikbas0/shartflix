import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfileEntity profile;
  final bool isRefreshing;
  final bool isUploadingPhoto;

  const ProfileLoaded({
    required this.profile,
    this.isRefreshing = false,
    this.isUploadingPhoto = false,
  });

  ProfileLoaded copyWith({
    UserProfileEntity? profile,
    bool? isRefreshing,
    bool? isUploadingPhoto,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
    );
  }

  @override
  List<Object?> get props => [profile, isRefreshing, isUploadingPhoto];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class PhotoUploadError extends ProfileError {
  const PhotoUploadError(String message) : super(message);
}
