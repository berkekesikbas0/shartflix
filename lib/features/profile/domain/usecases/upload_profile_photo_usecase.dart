import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

@injectable
class UploadProfilePhotoUseCase {
  final ProfileRepository _profileRepository;

  UploadProfilePhotoUseCase(this._profileRepository);

  Future<Either<Failure, String>> call(File photoFile) async {
    return await _profileRepository.uploadProfilePhoto(photoFile);
  }
}
