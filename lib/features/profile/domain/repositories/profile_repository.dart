import 'dart:io';
import 'package:dartz/dartz.dart';
import '../entities/user_profile_entity.dart';
import '../../../../core/error/failures.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfileEntity>> getUserProfile();
  Future<Either<Failure, void>> updateProfilePhoto(String photoUrl);
  Future<Either<Failure, String>> uploadProfilePhoto(File photoFile);
}
