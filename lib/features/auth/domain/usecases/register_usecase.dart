import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/constants/app_constants.dart';
import '../entities/auth_token_entity.dart';
import '../repositories/auth_repository.dart';

/// Register use case for user registration
@injectable
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  /// Execute registration operation
  Future<Either<Failure, AuthTokenEntity>> call({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // Input validation
    final validationFailure = _validateInputs(
      name,
      email,
      password,
      confirmPassword,
    );
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    // Clean inputs
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    // Execute registration
    return await _repository.register(
      name: cleanName,
      email: cleanEmail,
      password: cleanPassword,
      passwordConfirmation: cleanPassword,
    );
  }

  /// Validate registration inputs
  ValidationFailure? _validateInputs(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) {
    final errors = <String, List<String>>{};

    // Name validation
    if (name.trim().isEmpty) {
      errors['name'] = ['Ad soyad gereklidir'];
    } else if (name.trim().length < AppConstants.minNameLength) {
      errors['name'] = [
        'Ad soyad en az ${AppConstants.minNameLength} karakter olmalıdır',
      ];
    } else if (name.trim().length > AppConstants.maxNameLength) {
      errors['name'] = [
        'Ad soyad en fazla ${AppConstants.maxNameLength} karakter olabilir',
      ];
    } else if (!_isValidName(name.trim())) {
      errors['name'] = ['Ad soyad sadece harf ve boşluk içermelidir'];
    }

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
    } else if (!_isStrongPassword(password)) {
      errors['password'] = [
        'Şifre en az bir büyük harf, bir küçük harf ve bir rakam içermelidir',
      ];
    }

    // Confirm password validation
    if (confirmPassword.trim().isEmpty) {
      errors['confirm_password'] = ['Şifre tekrarı gereklidir'];
    } else if (password != confirmPassword) {
      errors['confirm_password'] = ['Şifreler eşleşmiyor'];
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

  /// Check if name is valid (letters and spaces only)
  bool _isValidName(String name) {
    final nameRegex = RegExp(r'^[a-zA-ZçğıöşüÇĞIİÖŞÜ\s]+$');
    return nameRegex.hasMatch(name);
  }

  /// Check if password is strong enough
  bool _isStrongPassword(String password) {
    // At least one uppercase letter, one lowercase letter, and one digit
    final strongPasswordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$');
    return strongPasswordRegex.hasMatch(password);
  }
}
