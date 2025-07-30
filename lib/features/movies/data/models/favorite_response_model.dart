import 'package:json_annotation/json_annotation.dart';

part 'favorite_response_model.g.dart';

/// Response wrapper for ServiceLabs API
@JsonSerializable()
class ServiceLabsFavoriteResponseModel {
  final Map<String, dynamic>? response;
  final Map<String, dynamic>? data;

  const ServiceLabsFavoriteResponseModel({this.response, this.data});

  factory ServiceLabsFavoriteResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$ServiceLabsFavoriteResponseModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ServiceLabsFavoriteResponseModelToJson(this);

  /// Check if response is successful
  bool get isSuccess => response?['code'] == 200;

  /// Get error message
  String get errorMessage => response?['message'] ?? 'Unknown error';
}

/// Response model for favorite/unfavorite API calls
@JsonSerializable()
class FavoriteResponseModel {
  final bool success;
  final String message;

  const FavoriteResponseModel({required this.success, required this.message});

  /// Convert from ServiceLabs API response
  factory FavoriteResponseModel.fromServiceLabsResponse(
    ServiceLabsFavoriteResponseModel apiResponse,
  ) {
    return FavoriteResponseModel(
      success: apiResponse.isSuccess,
      message: apiResponse.isSuccess ? 'Success' : apiResponse.errorMessage,
    );
  }

  factory FavoriteResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FavoriteResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteResponseModelToJson(this);

  @override
  String toString() =>
      'FavoriteResponseModel(success: $success, message: $message)';
}
