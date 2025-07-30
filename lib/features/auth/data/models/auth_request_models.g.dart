// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_request_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequestModel _$LoginRequestModelFromJson(Map<String, dynamic> json) =>
    LoginRequestModel(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestModelToJson(LoginRequestModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

RegisterRequestModel _$RegisterRequestModelFromJson(
        Map<String, dynamic> json) =>
    RegisterRequestModel(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
      termsAccepted: json['terms_accepted'] as bool? ?? true,
    );

Map<String, dynamic> _$RegisterRequestModelToJson(
        RegisterRequestModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'password_confirmation': instance.passwordConfirmation,
      'terms_accepted': instance.termsAccepted,
    };

ForgotPasswordRequestModel _$ForgotPasswordRequestModelFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordRequestModel(
      email: json['email'] as String,
    );

Map<String, dynamic> _$ForgotPasswordRequestModelToJson(
        ForgotPasswordRequestModel instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

ResetPasswordRequestModel _$ResetPasswordRequestModelFromJson(
        Map<String, dynamic> json) =>
    ResetPasswordRequestModel(
      email: json['email'] as String,
      token: json['token'] as String,
      password: json['password'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
    );

Map<String, dynamic> _$ResetPasswordRequestModelToJson(
        ResetPasswordRequestModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'token': instance.token,
      'password': instance.password,
      'password_confirmation': instance.passwordConfirmation,
    };

RefreshTokenRequestModel _$RefreshTokenRequestModelFromJson(
        Map<String, dynamic> json) =>
    RefreshTokenRequestModel(
      refreshToken: json['refresh_token'] as String,
    );

Map<String, dynamic> _$RefreshTokenRequestModelToJson(
        RefreshTokenRequestModel instance) =>
    <String, dynamic>{
      'refresh_token': instance.refreshToken,
    };
