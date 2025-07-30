import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/constants/app_constants.dart';
import '../entities/auth_token_entity.dart';
import '../repositories/auth_repository.dart';

/// Login use case for authentication
@injectable
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Execute login operation
  Future<Either<Failure, AuthTokenEntity>> call({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    // Input validation
    final validationFailure = _validateInputs(email, password);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    // Clean inputs
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    // Execute login
    return await _repository.login(
      email: cleanEmail,
      password: cleanPassword,
      rememberMe: rememberMe,
    );
  }

  /// Validate login inputs
  ValidationFailure? _validateInputs(String email, String password) {
    final errors = <String, List<String>>{};

    // Email validation
    if (email.trim().isEmpty) {
      errors['email'] = ['E-posta adresi gereklidir'];
    } else if (!_isValidEmail(email.trim())) {
      errors['email'] = ['Geçerli bir e-posta adresi giriniz'];
    }

    // Password validation
    if (password.trim().isEmpty) {
      errors['password'] = ['Şifre gereklidir'];
    } else if (password.length < AppConstants.minPasswordLength) {
      errors['password'] = [
        'Şifre en az ${AppConstants.minPasswordLength} karakter olmalıdır',
      ];
    } else if (password.length > AppConstants.maxPasswordLength) {
      errors['password'] = [
        'Şifre en fazla ${AppConstants.maxPasswordLength} karakter olabilir',
      ];
    }

    if (errors.isNotEmpty) {
      return ValidationFailure('Girilen bilgiler geçersiz', errors);
    }

    return null;
  }

  /// Check if email format is valid
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
