import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/storage_strategy.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_token_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_service.dart';
import '../models/auth_request_models.dart';
import '../models/auth_response_models.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final StorageManager _storageManager;
  final LoggerService _logger;

  AuthRepositoryImpl(this._apiService, this._storageManager, this._logger);

  @override
  Future<Either<Failure, AuthTokenEntity>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _logger.info('🔐 Attempting login for: $email');

      final request = LoginRequestModel(email: email, password: password);

      final response = await _apiService.login(request);

      if (response.success && response.token != null && response.user != null) {
        // Create token entity from string token
        final tokenEntity = AuthTokenEntity(
          accessToken: response.token!,
          refreshToken: '', // ServiceLabs doesn't provide refresh token
          tokenType: 'Bearer',
          expiresIn: 86400, // 24 hours default
          issuedAt: DateTime.now(),
        );

        final userEntity = response.user!.toEntity();

        // Store auth data securely
        await _storageManager.storeAuthToken(tokenEntity.accessToken);
        await _storageManager.storeUserData(_userEntityToMap(userEntity));

        _logger.info('✅ Login successful');
        return Right(tokenEntity);
      } else {
        final errorMessage =
            response.message.isNotEmpty ? response.message : 'Giriş yapılamadı';
        _logger.error('❌ Login failed: $errorMessage');
        return Left(AuthFailure(errorMessage));
      }
    } on DioException catch (e) {
      _logger.error('❌ Login network error', e);
      return Left(_handleDioError(e));
    } catch (e) {
      _logger.error('❌ Login unexpected error', e);
      return Left(
        UnknownFailure('Beklenmeyen bir hata oluştu: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthTokenEntity>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      _logger.info('📝 Attempting registration for: $email');

      final request = RegisterRequestModel(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      final response = await _apiService.register(request);

      // Handle ServiceLabs API response format
      if (response.success && response.token != null && response.user != null) {
        // Create token entity from string token
        final tokenEntity = AuthTokenEntity(
          accessToken: response.token!,
          refreshToken: '', // ServiceLabs doesn't provide refresh token
          tokenType: 'Bearer',
          expiresIn: 86400, // 24 hours default
          issuedAt: DateTime.now(),
        );

        final userEntity = response.user!.toEntity();

        // Store auth data securely
        await _storageManager.storeAuthToken(tokenEntity.accessToken);
        await _storageManager.storeUserData(_userEntityToMap(userEntity));

        _logger.info('✅ Registration successful');
        return Right(tokenEntity);
      } else {
        // Extract error message from ServiceLabs API response
        final errorMessage = response.message;
        final apiErrorCode = response.errorCode;

        if (apiErrorCode.isNotEmpty) {
          final failure = _handleServiceLabsApiError(
            apiErrorCode,
            errorMessage,
            400,
          );
          _logger.error('❌ Registration failed: ${failure.message}');
          return Left(failure);
        }

        // Generic error
        final failure = AuthFailure(
          errorMessage.isNotEmpty ? errorMessage : 'Kayıt oluşturulamadı',
        );
        _logger.error('❌ Registration failed: ${failure.message}');
        return Left(failure);
      }
    } on DioException catch (e) {
      _logger.error('❌ Registration network error', e);
      return Left(_handleDioError(e));
    } catch (e) {
      _logger.error('❌ Registration unexpected error', e);
      return Left(
        UnknownFailure('Beklenmeyen bir hata oluştu: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      _logger.info('👋 Attempting logout');

      final token = await _storageManager.getAuthToken();
      if (token != null) {
        try {
          await _apiService.logout('${AppConstants.bearerPrefix}$token');
        } catch (e) {
          // Even if API logout fails, we should clear local data
          _logger.warning(
            '⚠️ API logout failed, clearing local data anyway',
            e,
          );
        }
      }

      // Clear all auth data from local storage
      await _storageManager.clearAuthData();

      _logger.info('✅ Logout successful');
      return const Right(null);
    } catch (e) {
      _logger.error('❌ Logout error', e);
      // Even on error, try to clear local data
      try {
        await _storageManager.clearAuthData();
      } catch (clearError) {
        _logger.error('❌ Failed to clear auth data', clearError);
      }
      return Left(
        UnknownFailure('Çıkış yapılırken hata oluştu: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthTokenEntity>> refreshToken() async {
    try {
      _logger.info('🔄 Refreshing token');

      final refreshToken = await _storageManager.retrieve<String>(
        'refresh_token',
      );
      if (refreshToken == null) {
        return const Left(AuthFailure('Refresh token bulunamadı'));
      }

      final request = RefreshTokenRequestModel(refreshToken: refreshToken);
      final response = await _apiService.refreshToken(request);

      if (response.success && response.token != null) {
        // Create token entity from string token
        final tokenEntity = AuthTokenEntity(
          accessToken: response.token!,
          refreshToken: '', // ServiceLabs doesn't provide refresh token
          tokenType: 'Bearer',
          expiresIn: 86400, // 24 hours default
          issuedAt: DateTime.now(),
        );

        // Update stored tokens
        await _storageManager.storeAuthToken(tokenEntity.accessToken);

        // Update user data if provided
        if (response.user != null) {
          final userEntity = response.user!.toEntity();
          await _storageManager.storeUserData(_userEntityToMap(userEntity));
        }

        _logger.info('✅ Token refresh successful');
        return Right(tokenEntity);
      } else {
        _logger.error('❌ Token refresh failed: ${response.message}');
        return Left(AuthFailure(response.message));
      }
    } on DioException catch (e) {
      _logger.error('❌ Token refresh network error', e);
      return Left(_handleDioError(e));
    } catch (e) {
      _logger.error('❌ Token refresh unexpected error', e);
      return Left(
        UnknownFailure('Token yenilenirken hata oluştu: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword(String email) async {
    try {
      _logger.info('📧 Sending forgot password email to: $email');

      final request = ForgotPasswordRequestModel(email: email);
      final response = await _apiService.forgotPassword(request);

      if (response.success) {
        _logger.info('✅ Forgot password email sent');
        return Right(response.message);
      } else {
        _logger.error('❌ Forgot password failed: ${response.message}');
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      _logger.error('❌ Forgot password network error', e);
      return Left(_handleDioError(e));
    } catch (e) {
      _logger.error('❌ Forgot password unexpected error', e);
      return Left(
        UnknownFailure('Şifre sıfırlama isteği gönderilirken hata oluştu'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      _logger.info('🔑 Resetting password for: $email');

      final request = ResetPasswordRequestModel(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      final response = await _apiService.resetPassword(request);

      if (response.success) {
        _logger.info('✅ Password reset successful');
        return Right(response.message);
      } else {
        _logger.error('❌ Password reset failed: ${response.message}');
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      _logger.error('❌ Password reset network error', e);
      return Left(_handleDioError(e));
    } catch (e) {
      _logger.error('❌ Password reset unexpected error', e);
      return Left(UnknownFailure('Şifre sıfırlanırken hata oluştu'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserProfile() async {
    try {
      _logger.info('👤 Getting user profile');

      final token = await _storageManager.getAuthToken();
      if (token == null) {
        return const Left(AuthFailure('Oturum geçersiz'));
      }

      final response = await _apiService.getProfile(
        '${AppConstants.bearerPrefix}$token',
      );
      final userEntity = response.toEntity();

      // Update cached user data
      await _storageManager.storeUserData(_userEntityToMap(userEntity));

      _logger.info('✅ User profile retrieved');
      return Right(userEntity);
    } on DioException catch (e) {
      _logger.error('❌ Get profile network error', e);
      return Left(_handleDioError(e));
    } catch (e) {
      _logger.error('❌ Get profile unexpected error', e);
      return Left(UnknownFailure('Profil bilgileri alınırken hata oluştu'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      _logger.info('✏️ Updating user profile');

      final token = await _storageManager.getAuthToken();
      if (token == null) {
        return const Left(AuthFailure('Oturum geçersiz'));
      }

      final response = await _apiService.updateProfile(
        '${AppConstants.bearerPrefix}$token',
        profileData,
      );

      final userEntity = response.toEntity();

      // Update cached user data
      await _storageManager.storeUserData(_userEntityToMap(userEntity));

      _logger.info('✅ Profile updated successfully');
      return Right(userEntity);
    } on DioException catch (e) {
      _logger.error('❌ Update profile network error', e);
      return Left(_handleDioError(e));
    } catch (e) {
      _logger.error('❌ Update profile unexpected error', e);
      return Left(UnknownFailure('Profil güncellenirken hata oluştu'));
    }
  }

  @override
  Future<Either<Failure, String>> verifyEmail(
    Map<String, dynamic> verificationData,
  ) async {
    try {
      _logger.info('📧 Verifying email');

      final response = await _apiService.verifyEmail(verificationData);

      if (response.success) {
        _logger.info('✅ Email verified successfully');
        return Right(response.message);
      } else {
        _logger.error('❌ Email verification failed: ${response.message}');
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      _logger.error('❌ Email verification network error', e);
      return Left(_handleDioError(e));
    } catch (e) {
      _logger.error('❌ Email verification unexpected error', e);
      return Left(UnknownFailure('E-posta doğrulanırken hata oluştu'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await _storageManager.isAuthenticated();
    } catch (e) {
      _logger.error('❌ Error checking authentication status', e);
      return false;
    }
  }

  @override
  Future<UserEntity?> getCachedUser() async {
    try {
      final userData = await _storageManager.getUserData();
      if (userData != null) {
        return _mapToUserEntity(userData);
      }
      return null;
    } catch (e) {
      _logger.error('❌ Error getting cached user', e);
      return null;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await _storageManager.clearAuthData();
    } catch (e) {
      _logger.error('❌ Error clearing auth data', e);
      rethrow;
    }
  }

  // Helper methods

  Failure _handleDioError(DioException error) {
    _logger.error('🌐 Dio error: ${error.type} - ${error.message}');

    switch (error.type) {
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final responseData = error.response?.data;
        final message = _extractErrorMessage(responseData);

        // Handle ServiceLabs API specific error codes
        final apiErrorCode = _extractApiErrorCode(responseData);
        if (apiErrorCode.isNotEmpty) {
          return _handleServiceLabsApiError(apiErrorCode, message, statusCode);
        }

        switch (statusCode) {
          case 400:
            return AuthFailure(
              message.isNotEmpty ? message : 'Geçersiz istek',
              statusCode,
            );
          case 401:
            return AuthFailure(
              message.isNotEmpty ? message : 'Oturum geçersiz',
              statusCode,
            );
          case 422:
            return ValidationFailure(
              message.isNotEmpty ? message : 'Girilen bilgiler geçersiz',
              _extractValidationErrors(responseData),
              statusCode,
            );
          case 500:
            return ServerFailure('Sunucu hatası oluştu', statusCode);
          default:
            return ServerFailure(
              message.isNotEmpty ? message : 'Sunucu hatası',
              statusCode,
            );
        }

      case DioExceptionType.cancel:
        return const NetworkFailure('İstek iptal edildi');

      case DioExceptionType.connectionError:
        return const NetworkFailure('İnternet bağlantısı yok');

      case DioExceptionType.connectionTimeout:
        return const NetworkFailure('Bağlantı zaman aşımına uğradı');

      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Sunucu yanıt vermedi');

      case DioExceptionType.sendTimeout:
        return const NetworkFailure('İstek gönderilemedi');

      default:
        return NetworkFailure('Ağ hatası: ${error.message}');
    }
  }

  /// Handle ServiceLabs API specific error codes
  Failure _handleServiceLabsApiError(
    String errorCode,
    String originalMessage,
    int statusCode,
  ) {
    switch (errorCode.toUpperCase()) {
      case 'USER_EXISTS':
        return AuthFailure(
          'Bu email adresi zaten kayıtlı. Lütfen farklı bir email kullanın.',
          statusCode,
        );

      case 'INVALID_EMAIL_FORMAT':
        return ValidationFailure(
          'Geçersiz email formatı. Lütfen doğru bir email adresi girin.',
          {
            'email': ['Geçersiz email formatı'],
          },
          statusCode,
        );

      case 'INVALID_PASSWORD':
        return ValidationFailure(
          'Şifre çok kısa. En az 6 karakter olmalıdır.',
          {
            'password': ['Şifre en az 6 karakter olmalıdır'],
          },
          statusCode,
        );

      case 'INVALID_NAME':
        return ValidationFailure('Geçersiz isim. En az 2 karakter olmalıdır.', {
          'name': ['İsim en az 2 karakter olmalıdır'],
        }, statusCode);

      case 'EMAIL_REQUIRED':
        return ValidationFailure('Email adresi gereklidir.', {
          'email': ['Email adresi gereklidir'],
        }, statusCode);

      case 'PASSWORD_REQUIRED':
        return ValidationFailure('Şifre gereklidir.', {
          'password': ['Şifre gereklidir'],
        }, statusCode);

      case 'NAME_REQUIRED':
        return ValidationFailure('İsim gereklidir.', {
          'name': ['İsim gereklidir'],
        }, statusCode);

      case 'INVALID_CREDENTIALS':
        return AuthFailure(
          'Email veya şifre hatalı. Lütfen bilgilerinizi kontrol edin.',
          statusCode,
        );

      case 'USER_NOT_FOUND':
        return AuthFailure('Kullanıcı bulunamadı.', statusCode);

      case 'TOKEN_EXPIRED':
        return AuthFailure(
          'Oturum süresi doldu. Lütfen tekrar giriş yapın.',
          statusCode,
        );

      case 'INVALID_TOKEN':
        return AuthFailure(
          'Geçersiz oturum. Lütfen tekrar giriş yapın.',
          statusCode,
        );

      default:
        // If we don't recognize the error code, use the original message
        return AuthFailure(
          originalMessage.isNotEmpty
              ? originalMessage
              : 'Bir hata oluştu. Lütfen tekrar deneyin.',
          statusCode,
        );
    }
  }

  /// Extract API error code from ServiceLabs response
  String _extractApiErrorCode(dynamic responseData) {
    if (responseData == null) return '';

    // Handle response model objects
    if (responseData is RegisterResponseModel) {
      // Check if there's an error field in the response model
      return responseData.message.isNotEmpty ? responseData.message : '';
    }

    if (responseData is LoginResponseModel) {
      return responseData.message.isNotEmpty ? responseData.message : '';
    }

    // Handle raw response data (Map)
    if (responseData is Map<String, dynamic>) {
      // ServiceLabs API format: {"response": {"code": 400, "message": "USER_EXISTS"}, "data": {}}
      final response = responseData['response'];
      if (response is Map<String, dynamic>) {
        return response['message'] ?? '';
      }

      // Alternative format: {"error": "USER_EXISTS", "message": "..."}
      return responseData['error'] ?? '';
    }

    return '';
  }

  String _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return '';

    // Handle response model objects
    if (responseData is RegisterResponseModel) {
      return responseData.message.isNotEmpty
          ? responseData.message
          : 'Kayıt oluşturulamadı';
    }

    if (responseData is LoginResponseModel) {
      return responseData.message.isNotEmpty
          ? responseData.message
          : 'Giriş yapılamadı';
    }

    // Handle raw response data (Map)
    if (responseData is Map<String, dynamic>) {
      // ServiceLabs API format: {"response": {"code": 400, "message": "USER_EXISTS"}, "data": {}}
      final response = responseData['response'];
      if (response is Map<String, dynamic>) {
        return response['message'] ?? '';
      }

      // Standard format: {"message": "...", "error": "..."}
      return responseData['message'] ?? responseData['error'] ?? '';
    }

    return responseData.toString();
  }

  Map<String, List<String>>? _extractValidationErrors(dynamic responseData) {
    if (responseData == null) return null;

    if (responseData is Map<String, dynamic>) {
      final errors = responseData['errors'];
      if (errors is Map<String, dynamic>) {
        final validationErrors = <String, List<String>>{};
        errors.forEach((key, value) {
          if (value is List) {
            validationErrors[key] = value.map((e) => e.toString()).toList();
          } else {
            validationErrors[key] = [value.toString()];
          }
        });
        return validationErrors;
      }
    }

    return null;
  }

  Map<String, dynamic> _userEntityToMap(UserEntity user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone_number': user.phoneNumber,
      'profile_image_url': user.profileImageUrl,
      'email_verified_at': user.emailVerifiedAt?.toIso8601String(),
      'created_at': user.createdAt.toIso8601String(),
      'updated_at': user.updatedAt.toIso8601String(),
    };
  }

  UserEntity _mapToUserEntity(Map<String, dynamic> userData) {
    return UserEntity(
      id: userData['id'] ?? '',
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
      phoneNumber: userData['phone_number'],
      profileImageUrl: userData['profile_image_url'],
      emailVerifiedAt:
          userData['email_verified_at'] != null
              ? DateTime.tryParse(userData['email_verified_at'])
              : null,
      createdAt: DateTime.parse(
        userData['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        userData['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
