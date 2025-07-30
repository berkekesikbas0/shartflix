import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';
import '../storage/storage_strategy.dart';
import 'logger_service.dart';

/// API service provider with Dio configuration
@singleton
class ApiService {
  late final Dio _dio;
  final StorageManager _storageManager;
  final LoggerService _logger;

  ApiService(this._storageManager, this._logger) {
    _dio = Dio();
    _configureDio();
  }

  /// Get configured Dio instance
  Dio get dio => _dio;

  /// Configure Dio with interceptors and options
  void _configureDio() {
    // Base options
    _dio.options = BaseOptions(
      baseUrl: AppConstants.authBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        AppConstants.contentTypeHeader: 'application/json',
        AppConstants.acceptHeader: 'application/json',
      },
    );

    // Add interceptors
    _dio.interceptors.addAll([
      _ServiceLabsAuthInterceptor(_storageManager, _logger),
      _LoggingInterceptor(_logger),
      _ErrorInterceptor(_logger),
    ]);
  }

  /// Update base URL if needed
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    _logger.info('🌐 Base URL updated: $baseUrl');
  }
}

/// ServiceLabs API specific authentication interceptor
class _ServiceLabsAuthInterceptor extends Interceptor {
  final StorageManager _storageManager;
  final LoggerService _logger;

  _ServiceLabsAuthInterceptor(this._storageManager, this._logger);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // For movies endpoints, use user token as Authorization Bearer
      if (options.path.contains('/movie/')) {
        final userToken = await _storageManager.getAuthToken();
        if (userToken != null && userToken.isNotEmpty) {
          options.headers[AppConstants.authorizationHeader] =
              '${AppConstants.bearerPrefix}$userToken';
          _logger.debug('🎬 Added user token for movies: ${options.path}');
        } else {
          _logger.warning('⚠️ No user token available for movies endpoint');
        }
      }
      // For photo upload endpoint, ensure we're using the JWT token
      else if (options.path.contains(AppConstants.uploadPhotoEndpoint)) {
        final userToken = await _storageManager.getAuthToken();
        if (userToken != null && userToken.isNotEmpty) {
          options.headers[AppConstants.authorizationHeader] = userToken;
          _logger.debug('📸 Added JWT token to photo upload request');
        } else {
          _logger.warning('⚠️ No user token available for photo upload');
        }
      } else {
        // For auth endpoints, use API key
        options.headers[AppConstants.authorizationHeader] =
            '${AppConstants.bearerPrefix}${AppConstants.apiKey}';

        // For endpoints that need user authentication, add user token
        final needsUserAuth = !_isPublicEndpoint(options.path);
        if (needsUserAuth) {
          final userToken = await _storageManager.getAuthToken();
          if (userToken != null && userToken.isNotEmpty) {
            // API "JWTTOKEN" formatında bekliyor, "Bearer" prefix'i kaldırıyoruz
            options.headers[AppConstants.authorizationHeader] = userToken;
            _logger.debug('🔐 Added JWT token to request: $userToken');
          }
        }

        _logger.debug('🔑 Added API key to request: ${options.path}');
      }
    } catch (e) {
      _logger.error('❌ Error adding auth headers', e);
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - token expired or invalid API key
    if (err.response?.statusCode == 401) {
      _logger.warning('🔑 Authentication failed, checking error details');

      // If it's a user token issue, clear user auth data
      if (err.requestOptions.headers.containsKey('X-User-Token')) {
        try {
          await _storageManager.clearAuthData();
          _logger.info('🧹 Cleared user auth data due to 401');
        } catch (e) {
          _logger.error('❌ Error clearing auth data', e);
        }
      }
    }

    handler.next(err);
  }

  /// Check if endpoint is completely public (no auth headers at all)
  bool _isCompletelyPublicEndpoint(String path) {
    // No completely public endpoints - all require some form of auth
    return false;
  }

  /// Check if endpoint is public (doesn't need user authentication)
  bool _isPublicEndpoint(String path) {
    final publicPaths = [
      AppConstants.loginEndpoint, // /user/login
      AppConstants.registerEndpoint, // /user/register
      AppConstants.forgotPasswordEndpoint,
      AppConstants.resetPasswordEndpoint,
      AppConstants.verifyEmailEndpoint,
      AppConstants.moviesEndpoint, // /movie/list - needs API key only
    ];

    return publicPaths.any((publicPath) => path.contains(publicPath));
  }
}

/// Logging interceptor for request/response logging
class _LoggingInterceptor extends Interceptor {
  final LoggerService _logger;

  _LoggingInterceptor(this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Detailed request logging
    print('🚀 === HTTP REQUEST START ===');
    print('Method: ${options.method.toUpperCase()}');
    print('Full URL: ${options.uri}');
    print('Base URL: ${options.baseUrl}');
    print('Path: ${options.path}');
    print('Headers: ${_sanitizeHeaders(options.headers)}');
    print('Query Parameters: ${options.queryParameters}');
    print('Request Data: ${_sanitizeData(options.data)}');
    print('🚀 === HTTP REQUEST END ===');

    _logger.debug(
      '🚀 ${options.method.toUpperCase()} ${options.uri}\n'
      'Headers: ${_sanitizeHeaders(options.headers)}\n'
      'Data: ${_sanitizeData(options.data)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Detailed response logging
    print('✅ === HTTP RESPONSE START ===');
    print('Status Code: ${response.statusCode}');
    print('Status Message: ${response.statusMessage}');
    print('URL: ${response.requestOptions.uri}');
    print('Response Headers: ${response.headers.map}');
    print('Response Data: ${_sanitizeResponseData(response.data)}');
    print('✅ === HTTP RESPONSE END ===');

    _logger.debug(
      '✅ ${response.statusCode} ${response.requestOptions.uri}\n'
      'Data: ${_sanitizeResponseData(response.data)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Detailed error logging
    print('❌ === HTTP ERROR START ===');
    print('Error Type: ${err.type}');
    print('Status Code: ${err.response?.statusCode ?? 'NO_STATUS'}');
    print('Status Message: ${err.response?.statusMessage ?? 'NO_MESSAGE'}');
    print('URL: ${err.requestOptions.uri}');
    print('Error Message: ${err.message}');
    print('Request Headers: ${_sanitizeHeaders(err.requestOptions.headers)}');
    print('Request Data: ${_sanitizeData(err.requestOptions.data)}');
    print('Response Headers: ${err.response?.headers.map}');
    print('Response Data: ${_sanitizeResponseData(err.response?.data)}');
    print('❌ === HTTP ERROR END ===');

    _logger.error(
      '❌ ${err.response?.statusCode ?? 'NO_STATUS'} ${err.requestOptions.uri}\n'
      'Error: ${err.message}\n'
      'Response: ${_sanitizeResponseData(err.response?.data)}',
    );
    handler.next(err);
  }

  /// Hide sensitive data in headers for logging
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);

    // Hide sensitive headers but show first few characters for debugging
    final sensitiveKeys = ['authorization', 'x-api-key', 'x-user-token'];
    for (final key in sensitiveKeys) {
      if (sanitized.containsKey(key)) {
        final value = sanitized[key].toString();
        if (value.length > 8) {
          sanitized[key] = '${value.substring(0, 8)}***hidden***';
        } else {
          sanitized[key] = '***hidden***';
        }
      }
    }

    return sanitized;
  }

  /// Hide password and sensitive data in request body
  dynamic _sanitizeData(dynamic data) {
    if (data is Map) {
      final sanitized = Map.from(data);
      final sensitiveKeys = ['password', 'password_confirmation', 'token'];

      for (final key in sensitiveKeys) {
        if (sanitized.containsKey(key)) {
          sanitized[key] = '***hidden***';
        }
      }

      return sanitized;
    }

    return data;
  }

  /// Hide sensitive data in response for logging
  dynamic _sanitizeResponseData(dynamic data) {
    if (data is Map) {
      final sanitized = Map.from(data);
      final sensitiveKeys = [
        'access_token',
        'refresh_token',
        'token',
        'password',
      ];

      for (final key in sensitiveKeys) {
        if (sanitized.containsKey(key)) {
          sanitized[key] = '***hidden***';
        }
      }

      return sanitized;
    }

    return data;
  }
}

/// Error interceptor for handling common errors
class _ErrorInterceptor extends Interceptor {
  final LoggerService _logger;

  _ErrorInterceptor(this._logger);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log specific error types
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        _logger.error('⏰ Connection timeout');
        break;
      case DioExceptionType.sendTimeout:
        _logger.error('⏰ Send timeout');
        break;
      case DioExceptionType.receiveTimeout:
        _logger.error('⏰ Receive timeout');
        break;
      case DioExceptionType.connectionError:
        _logger.error('🌐 Connection error');
        break;
      case DioExceptionType.badResponse:
        _logger.error('📡 Bad response: ${err.response?.statusCode}');
        break;
      case DioExceptionType.cancel:
        _logger.warning('🚫 Request cancelled');
        break;
      case DioExceptionType.badCertificate:
        _logger.error('🔒 Bad certificate error');
        break;
      case DioExceptionType.unknown:
        _logger.error('❓ Unknown error: ${err.message}');
        break;
    }

    handler.next(err);
  }
}
