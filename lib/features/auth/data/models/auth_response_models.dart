import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_token_entity.dart';

part 'auth_response_models.g.dart';

/// User model for ServiceLabs API responses
@JsonSerializable()
class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  @JsonKey(name: 'photoUrl')
  final String? photoUrl;
  @JsonKey(name: '_id')
  final String? mongoId;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.mongoId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phoneNumber: null,
      profileImageUrl: photoUrl,
      emailVerifiedAt: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, name, email, photoUrl, mongoId];
}

/// Auth token model for API responses
@JsonSerializable()
class AuthTokenModel extends Equatable {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokenModelToJson(this);

  /// Convert to domain entity
  AuthTokenEntity toEntity() {
    return AuthTokenEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
      issuedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, tokenType, expiresIn];
}

/// Login response model for ServiceLabs API
@JsonSerializable()
class LoginResponseModel extends Equatable {
  final Map<String, dynamic>? response;
  final Map<String, dynamic>? data;

  const LoginResponseModel({this.response, this.data});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);

  /// Get token from data
  String? get token {
    if (data != null && data!['token'] != null) {
      return data!['token'] as String;
    }
    return null;
  }

  /// Get user from data
  UserModel? get user {
    if (data != null) {
      try {
        return UserModel.fromJson(data!);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Check if login was successful
  bool get success => token != null && user != null;

  /// Get error message from response
  String get message {
    if (response != null && response!['message'] != null) {
      return response!['message'] as String;
    }
    return '';
  }

  /// Get error code from response
  String get errorCode {
    if (response != null && response!['code'] != null) {
      return response!['code'].toString();
    }
    return '';
  }

  @override
  List<Object?> get props => [response, data];
}

/// Register response model for ServiceLabs API
@JsonSerializable()
class RegisterResponseModel extends Equatable {
  final Map<String, dynamic>? response;
  final Map<String, dynamic>? data;

  const RegisterResponseModel({this.response, this.data});

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseModelToJson(this);

  /// Get token from data
  String? get token {
    if (data != null && data!['token'] != null) {
      return data!['token'] as String;
    }
    return null;
  }

  /// Get user from data
  UserModel? get user {
    if (data != null) {
      try {
        return UserModel.fromJson(data!);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Check if registration was successful
  bool get success => token != null && user != null;

  /// Get error message from response
  String get message {
    if (response != null && response!['message'] != null) {
      return response!['message'] as String;
    }
    return '';
  }

  /// Get error code from response
  String get errorCode {
    if (response != null && response!['code'] != null) {
      return response!['code'].toString();
    }
    return '';
  }

  @override
  List<Object?> get props => [response, data];
}

/// Logout response model
@JsonSerializable()
class LogoutResponseModel extends Equatable {
  final bool success;
  final String message;

  const LogoutResponseModel({required this.success, required this.message});

  factory LogoutResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LogoutResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LogoutResponseModelToJson(this);

  @override
  List<Object?> get props => [success, message];
}

/// Forgot password response model
@JsonSerializable()
class ForgotPasswordResponseModel extends Equatable {
  final bool success;
  final String message;

  const ForgotPasswordResponseModel({
    required this.success,
    required this.message,
  });

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordResponseModelToJson(this);

  @override
  List<Object?> get props => [success, message];
}

/// Generic API error response model
@JsonSerializable()
class ApiErrorResponseModel extends Equatable {
  final bool success;
  final String message;
  final Map<String, dynamic>? errors;
  final int? code;

  const ApiErrorResponseModel({
    required this.success,
    required this.message,
    this.errors,
    this.code,
  });

  factory ApiErrorResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorResponseModelToJson(this);

  @override
  List<Object?> get props => [success, message, errors, code];
}
