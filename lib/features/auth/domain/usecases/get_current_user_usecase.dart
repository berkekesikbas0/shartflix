import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Get current user use case
@injectable
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  /// Get current user from cache or API
  Future<Either<Failure, UserEntity>> call({bool forceRefresh = false}) async {
    if (forceRefresh) {
      // Force refresh from API
      return await _repository.getUserProfile();
    }

    // Try to get from cache first
    final cachedUser = await _repository.getCachedUser();
    if (cachedUser != null) {
      return Right(cachedUser);
    }

    // Fallback to API
    return await _repository.getUserProfile();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _repository.isAuthenticated();
  }

  /// Get cached user data
  Future<UserEntity?> getCachedUser() async {
    return await _repository.getCachedUser();
  }
}
