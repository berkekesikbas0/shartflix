// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_movies_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceLabsFavoritesResponseModel _$ServiceLabsFavoritesResponseModelFromJson(
        Map<String, dynamic> json) =>
    ServiceLabsFavoritesResponseModel(
      response: json['response'] as Map<String, dynamic>?,
      data: (json['data'] as List<dynamic>)
          .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ServiceLabsFavoritesResponseModelToJson(
        ServiceLabsFavoritesResponseModel instance) =>
    <String, dynamic>{
      'response': instance.response,
      'data': instance.data,
    };

FavoriteMoviesResponseModel _$FavoriteMoviesResponseModelFromJson(
        Map<String, dynamic> json) =>
    FavoriteMoviesResponseModel(
      movies: (json['movies'] as List<dynamic>)
          .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FavoriteMoviesResponseModelToJson(
        FavoriteMoviesResponseModel instance) =>
    <String, dynamic>{
      'movies': instance.movies,
    };
