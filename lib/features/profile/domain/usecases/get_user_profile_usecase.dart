import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';
import '../../../../core/error/failures.dart';

@injectable
class GetUserProfileUseCase {
  final ProfileRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<Either<Failure, UserProfileEntity>> call() async {
    return await _repository.getUserProfile();
  }
}
