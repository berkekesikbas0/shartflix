import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../entities/auth_token_entity.dart';

/// Auth repository interface for domain layer
abstract class AuthRepository {
  /// Login user with email and password
  Future<Either<Failure, AuthTokenEntity>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  /// Register new user
  Future<Either<Failure, AuthTokenEntity>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Refresh authentication token
  Future<Either<Failure, AuthTokenEntity>> refreshToken();

  /// Send forgot password email
  Future<Either<Failure, String>> forgotPassword(String email);

  /// Reset password with token
  Future<Either<Failure, String>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  });

  /// Get current user profile
  Future<Either<Failure, UserEntity>> getUserProfile();

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateProfile(
    Map<String, dynamic> profileData,
  );

  /// Verify email with verification data
  Future<Either<Failure, String>> verifyEmail(
    Map<String, dynamic> verificationData,
  );

  /// Check if user is authenticated locally
  Future<bool> isAuthenticated();

  /// Get cached user data
  Future<UserEntity?> getCachedUser();

  /// Clear all authentication data
  Future<void> clearAuthData();
}
