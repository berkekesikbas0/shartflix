class AppConstants {
  // App Info
  static const String appName = 'Shartflix';
  static const String appVersion = '1.0.0';

  // ServiceLabs API Configuration - Fixed according to documentation
  static const String baseUrl = 'https://caseapi.servicelabs.tech';
  static const String authBaseUrl = baseUrl; // Remove /api suffix

  // API Key for ServiceLabs (test key from documentation)
  static const String apiKey = '2626'; // Test API key from documentation

  // Auth Endpoints - CORRECTED according to ServiceLabs API documentation
  static const String loginEndpoint = '/user/login';
  static const String registerEndpoint = '/user/register';
  static const String logoutEndpoint = '/user/logout';
  static const String refreshTokenEndpoint = '/user/refresh';
  static const String forgotPasswordEndpoint = '/user/forgot-password';
  static const String resetPasswordEndpoint = '/user/reset-password';
  static const String verifyEmailEndpoint = '/user/verify-email';
  static const String profileEndpoint = '/user/profile';
  static const String uploadPhotoEndpoint = '/user/upload_photo';

  // Movies Endpoints
  static const String moviesEndpoint = '/movie/list';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'selected_language';
  static const String themeKey = 'theme_mode';

  // HTTP Headers
  static const String authorizationHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String acceptHeader = 'Accept';
  static const String bearerPrefix = 'Bearer ';
  static const String apiKeyHeader = 'X-API-Key';

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 5; // 5 movies per page as requested
  static const int maxRetryAttempts = 3;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
}
