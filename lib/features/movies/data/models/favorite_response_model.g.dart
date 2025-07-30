// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceLabsFavoriteResponseModel _$ServiceLabsFavoriteResponseModelFromJson(
        Map<String, dynamic> json) =>
    ServiceLabsFavoriteResponseModel(
      response: json['response'] as Map<String, dynamic>?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ServiceLabsFavoriteResponseModelToJson(
        ServiceLabsFavoriteResponseModel instance) =>
    <String, dynamic>{
      'response': instance.response,
      'data': instance.data,
    };

FavoriteResponseModel _$FavoriteResponseModelFromJson(
        Map<String, dynamic> json) =>
    FavoriteResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$FavoriteResponseModelToJson(
        FavoriteResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };
