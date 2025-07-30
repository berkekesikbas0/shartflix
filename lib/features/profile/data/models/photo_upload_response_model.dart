import 'package:json_annotation/json_annotation.dart';

part 'photo_upload_response_model.g.dart';

@JsonSerializable()
class PhotoUploadResponseModel {
  final String photoUrl;

  PhotoUploadResponseModel({required this.photoUrl});

  factory PhotoUploadResponseModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('data') && json['data'] is Map) {
      // Handle case where data is wrapped in a data object
      final data = json['data'] as Map<String, dynamic>;
      if (data.containsKey('photoUrl')) {
        return PhotoUploadResponseModel(photoUrl: data['photoUrl'] as String);
      }
    }

    // Direct photoUrl in response root
    if (json.containsKey('photoUrl')) {
      return PhotoUploadResponseModel(photoUrl: json['photoUrl'] as String);
    }

    // If we can't find photoUrl, return empty string (will be handled by error checks)
    print('⚠️ Could not find photoUrl in response: $json');
    return PhotoUploadResponseModel(photoUrl: '');
  }

  Map<String, dynamic> toJson() => _$PhotoUploadResponseModelToJson(this);
}
