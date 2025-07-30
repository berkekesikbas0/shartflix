import 'package:logger/logger.dart';
import 'package:injectable/injectable.dart';

enum LogLevel { debug, info, warning, error }

@singleton
class LoggerService {
  late Logger _logger;

  LoggerService() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
  }

  /// Log debug messages
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info messages
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning messages
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error messages
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log with custom level
  void log(
    LogLevel level,
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    switch (level) {
      case LogLevel.debug:
        debug(message, error, stackTrace);
        break;
      case LogLevel.info:
        info(message, error, stackTrace);
        break;
      case LogLevel.warning:
        warning(message, error, stackTrace);
        break;
      case LogLevel.error:
        error(message, error, stackTrace);
        break;
    }
  }

  /// Log API requests
  void logApiRequest(String method, String url, Map<String, dynamic>? data) {
    info('🌐 API Request: $method $url${data != null ? '\nData: $data' : ''}');
  }

  /// Log API responses
  void logApiResponse(String url, int statusCode, dynamic responseData) {
    if (statusCode >= 200 && statusCode < 300) {
      info('✅ API Response: $url\nStatus: $statusCode\nData: $responseData');
    } else {
      error('❌ API Error: $url\nStatus: $statusCode\nData: $responseData');
    }
  }

  /// Log navigation events
  void logNavigation(String from, String to) {
    info('🚀 Navigation: $from → $to');
  }

  /// Log user actions
  void logUserAction(String action, Map<String, dynamic>? parameters) {
    info(
      '👤 User Action: $action${parameters != null ? '\nParams: $parameters' : ''}',
    );
  }

  /// Log performance metrics
  void logPerformance(String operation, Duration duration) {
    info('⚡ Performance: $operation took ${duration.inMilliseconds}ms');
  }
}
