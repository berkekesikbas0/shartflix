import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/photo_upload_response_model.dart';

part 'profile_api_service.g.dart';

@RestApi()
abstract class ProfileApiService {
  factory ProfileApiService(Dio dio, {String baseUrl}) = _ProfileApiService;

  @GET('/user/profile')
  Future<dynamic> getUserProfile();

  @POST('/user/upload_photo')
  @MultiPart()
  Future<PhotoUploadResponseModel> uploadProfilePhoto(
    @Part(name: 'file') File file,
  );
}
