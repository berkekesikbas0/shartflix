import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/auth_request_models.dart';
import '../models/auth_response_models.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio) = _AuthApiService;

  /// Login user
  @POST(AppConstants.loginEndpoint)
  Future<LoginResponseModel> login(@Body() LoginRequestModel request);

  /// Register new user
  @POST(AppConstants.registerEndpoint)
  Future<RegisterResponseModel> register(@Body() RegisterRequestModel request);

  /// Logout current user
  @POST(AppConstants.logoutEndpoint)
  Future<LogoutResponseModel> logout(
    @Header(AppConstants.authorizationHeader) String token,
  );

  /// Refresh authentication token
  @POST(AppConstants.refreshTokenEndpoint)
  Future<LoginResponseModel> refreshToken(
    @Body() RefreshTokenRequestModel request,
  );

  /// Send forgot password email
  @POST(AppConstants.forgotPasswordEndpoint)
  Future<ForgotPasswordResponseModel> forgotPassword(
    @Body() ForgotPasswordRequestModel request,
  );

  /// Reset password with token
  @POST(AppConstants.resetPasswordEndpoint)
  Future<ForgotPasswordResponseModel> resetPassword(
    @Body() ResetPasswordRequestModel request,
  );

  /// Get user profile
  @GET(AppConstants.profileEndpoint)
  Future<UserModel> getProfile(
    @Header(AppConstants.authorizationHeader) String token,
  );

  /// Update user profile
  @PUT(AppConstants.profileEndpoint)
  Future<UserModel> updateProfile(
    @Header(AppConstants.authorizationHeader) String token,
    @Body() Map<String, dynamic> profileData,
  );

  /// Verify email
  @POST(AppConstants.verifyEmailEndpoint)
  Future<ApiErrorResponseModel> verifyEmail(
    @Body() Map<String, dynamic> verificationData,
  );
}
