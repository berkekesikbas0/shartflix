import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../repositories/profile_repository.dart';
import '../../../../core/error/failures.dart';

@injectable
class UpdateProfilePhotoUseCase {
  final ProfileRepository _repository;

  UpdateProfilePhotoUseCase(this._repository);

  Future<Either<Failure, void>> call(String photoUrl) async {
    return await _repository.updateProfilePhoto(photoUrl);
  }
}
