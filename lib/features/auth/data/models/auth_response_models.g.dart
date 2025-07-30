// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      mongoId: json['_id'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      '_id': instance.mongoId,
    };

AuthTokenModel _$AuthTokenModelFromJson(Map<String, dynamic> json) =>
    AuthTokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
    );

Map<String, dynamic> _$AuthTokenModelToJson(AuthTokenModel instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
    };

LoginResponseModel _$LoginResponseModelFromJson(Map<String, dynamic> json) =>
    LoginResponseModel(
      response: json['response'] as Map<String, dynamic>?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$LoginResponseModelToJson(LoginResponseModel instance) =>
    <String, dynamic>{
      'response': instance.response,
      'data': instance.data,
    };

RegisterResponseModel _$RegisterResponseModelFromJson(
        Map<String, dynamic> json) =>
    RegisterResponseModel(
      response: json['response'] as Map<String, dynamic>?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RegisterResponseModelToJson(
        RegisterResponseModel instance) =>
    <String, dynamic>{
      'response': instance.response,
      'data': instance.data,
    };

LogoutResponseModel _$LogoutResponseModelFromJson(Map<String, dynamic> json) =>
    LogoutResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$LogoutResponseModelToJson(
        LogoutResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };

ForgotPasswordResponseModel _$ForgotPasswordResponseModelFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$ForgotPasswordResponseModelToJson(
        ForgotPasswordResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };

ApiErrorResponseModel _$ApiErrorResponseModelFromJson(
        Map<String, dynamic> json) =>
    ApiErrorResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      errors: json['errors'] as Map<String, dynamic>?,
      code: (json['code'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ApiErrorResponseModelToJson(
        ApiErrorResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'errors': instance.errors,
      'code': instance.code,
    };
