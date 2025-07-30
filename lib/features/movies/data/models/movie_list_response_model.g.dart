// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceLabsApiResponseModel _$ServiceLabsApiResponseModelFromJson(
        Map<String, dynamic> json) =>
    ServiceLabsApiResponseModel(
      response: json['response'] as Map<String, dynamic>?,
      data: json['data'] == null
          ? null
          : MovieListDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ServiceLabsApiResponseModelToJson(
        ServiceLabsApiResponseModel instance) =>
    <String, dynamic>{
      'response': instance.response,
      'data': instance.data,
    };

MovieListDataModel _$MovieListDataModelFromJson(Map<String, dynamic> json) =>
    MovieListDataModel(
      movies: (json['movies'] as List<dynamic>)
          .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : PaginationModel.fromJson(
              json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MovieListDataModelToJson(MovieListDataModel instance) =>
    <String, dynamic>{
      'movies': instance.movies,
      'pagination': instance.pagination,
    };

PaginationModel _$PaginationModelFromJson(Map<String, dynamic> json) =>
    PaginationModel(
      totalCount: (json['totalCount'] as num).toInt(),
      perPage: (json['perPage'] as num).toInt(),
      maxPage: (json['maxPage'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
    );

Map<String, dynamic> _$PaginationModelToJson(PaginationModel instance) =>
    <String, dynamic>{
      'totalCount': instance.totalCount,
      'perPage': instance.perPage,
      'maxPage': instance.maxPage,
      'currentPage': instance.currentPage,
    };

MovieListResponseModel _$MovieListResponseModelFromJson(
        Map<String, dynamic> json) =>
    MovieListResponseModel(
      movies: (json['movies'] as List<dynamic>)
          .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: (json['totalPages'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
    );

Map<String, dynamic> _$MovieListResponseModelToJson(
        MovieListResponseModel instance) =>
    <String, dynamic>{
      'movies': instance.movies,
      'totalPages': instance.totalPages,
      'currentPage': instance.currentPage,
    };
