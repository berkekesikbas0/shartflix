import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/storage/storage_strategy.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_profile_model.dart';
import '../datasources/profile_api_service.dart';
import '../../../movies/domain/repositories/movies_repository.dart';
import '../../../../core/injection/injection.dart';

@Injectable(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService _apiService;
  final MoviesRepository _moviesRepository;

  ProfileRepositoryImpl(this._apiService, this._moviesRepository);

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile() async {
    try {
      final profileApiService = getIt<ProfileApiService>();
      final response = await profileApiService.getUserProfile();

      // API response'u Map'e cast et ve UserProfileModel'e dönüştür
      final responseMap = response as Map<String, dynamic>;
      final userProfile = UserProfileModel.fromApiResponse(responseMap);

      // Favori filmleri movies repository'den al
      final favoriteMoviesResult = await _moviesRepository.getFavoriteMovies();

      List<FavoriteMovieEntity> favoriteMovies = [];
      favoriteMoviesResult.fold(
        (failure) {
          // Favori filmler yüklenemezse boş liste kullan
          print('Failed to load favorite movies: ${failure.message}');
        },
        (movies) {
          favoriteMovies =
              movies
                  .map(
                    (movie) => FavoriteMovieEntity(
                      id: movie.id,
                      title: movie.title,
                      productionCompany:
                          null, // MovieEntity'de productionCompany yok
                      posterUrl: movie.posterUrl,
                    ),
                  )
                  .toList();
        },
      );

      final profileWithFavorites = userProfile.copyWith(
        favoriteMovies: favoriteMovies,
      );

      return Right(profileWithFavorites);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return Left(AuthFailure('Unauthorized - Please login again'));
      }
      return Left(ServerFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfilePhoto(String photoUrl) async {
    try {
      // Mock implementation - in real app this would update the API
      await Future.delayed(const Duration(milliseconds: 500));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePhoto(File photoFile) async {
    try {
      print('📸 Starting profile photo upload: ${photoFile.path}');
      print('📏 File size: ${(await photoFile.length()) / 1024} KB');
      print('📋 File extension: ${photoFile.path.split('.').last}');
      print('📋 File mime type: ${_getMimeType(photoFile.path)}');

      // Create Dio instance directly for debugging
      final dio = _apiService.dio;

      // Add explicit auth header for this request
      final userToken = await getIt<StorageManager>().getAuthToken();
      if (userToken != null && userToken.isNotEmpty) {
        print('🔑 Using auth token: ${userToken.substring(0, 15)}...');
      } else {
        print('⚠️ No auth token found');
      }

      // Create form data manually for better control
      final formData = FormData();
      formData.files.add(
        MapEntry(
          'file',
          await MultipartFile.fromFile(
            photoFile.path,
            filename: 'profile_photo.${photoFile.path.split('.').last}',
          ),
        ),
      );

      print(
        '🚀 Sending request to ${AppConstants.baseUrl}${AppConstants.uploadPhotoEndpoint}',
      );
      final response = await dio.post(
        AppConstants.uploadPhotoEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': userToken ?? '',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('✅ Photo upload response: ${response.statusCode}');
      print('📄 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        String photoUrl = '';

        if (responseData is Map &&
            responseData.containsKey('data') &&
            responseData['data'] is Map &&
            responseData['data'].containsKey('photoUrl')) {
          photoUrl = responseData['data']['photoUrl'] as String;
        } else if (responseData is Map &&
            responseData.containsKey('photoUrl')) {
          photoUrl = responseData['photoUrl'] as String;
        } else {
          print('⚠️ Could not find photoUrl in response: $responseData');
          return Left(ServerFailure('Could not parse photo URL from response'));
        }

        print('🖼️ Extracted photo URL: $photoUrl');

        // Explicitly refresh user profile data
        try {
          final profileApiService = getIt<ProfileApiService>();
          final profileResponse = await profileApiService.getUserProfile();
          print('👤 Profile after photo upload: $profileResponse');
        } catch (e) {
          print('⚠️ Failed to refresh profile after upload: $e');
        }

        return Right(photoUrl);
      } else {
        return Left(
          ServerFailure('Failed to upload photo: ${response.statusMessage}'),
        );
      }
    } on DioException catch (e) {
      print('❌ Dio error during photo upload: ${e.message}');
      print('📡 Status code: ${e.response?.statusCode}');
      print('📝 Response data: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        return Left(AuthFailure('Unauthorized - Please login again'));
      } else if (e.response?.statusCode == 400) {
        return Left(ServerFailure('Invalid file format or size'));
      }
      return Left(ServerFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      print('⚠️ Unexpected error during photo upload: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  // Helper to get mime type from file extension
  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}
