import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'auth_request_models.g.dart';

/// Login request model
@JsonSerializable()
class LoginRequestModel extends Equatable {
  final String email;
  final String password;

  const LoginRequestModel({required this.email, required this.password});

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);

  @override
  List<Object?> get props => [email, password];
}

/// Register request model
@JsonSerializable()
class RegisterRequestModel extends Equatable {
  final String name;
  final String email;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;
  @JsonKey(name: 'terms_accepted')
  final bool termsAccepted;

  const RegisterRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.termsAccepted = true,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);

  @override
  List<Object?> get props => [
    name,
    email,
    password,
    passwordConfirmation,
    termsAccepted,
  ];
}

/// Forgot password request model
@JsonSerializable()
class ForgotPasswordRequestModel extends Equatable {
  final String email;

  const ForgotPasswordRequestModel({required this.email});

  factory ForgotPasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordRequestModelToJson(this);

  @override
  List<Object?> get props => [email];
}

/// Reset password request model
@JsonSerializable()
class ResetPasswordRequestModel extends Equatable {
  final String email;
  final String token;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;

  const ResetPasswordRequestModel({
    required this.email,
    required this.token,
    required this.password,
    required this.passwordConfirmation,
  });

  factory ResetPasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordRequestModelToJson(this);

  @override
  List<Object?> get props => [email, token, password, passwordConfirmation];
}

/// Refresh token request model
@JsonSerializable()
class RefreshTokenRequestModel extends Equatable {
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  const RefreshTokenRequestModel({required this.refreshToken});

  factory RefreshTokenRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestModelToJson(this);

  @override
  List<Object?> get props => [refreshToken];
}
