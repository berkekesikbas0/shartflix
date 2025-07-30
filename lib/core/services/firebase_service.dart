import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'logger_service.dart';

@singleton
class FirebaseService {
  final LoggerService _logger;

  FirebaseService(this._logger);

  FirebaseAnalytics? _analytics;
  FirebaseCrashlytics? _crashlytics;

  FirebaseAnalytics? get analytics => _analytics;
  FirebaseCrashlytics? get crashlytics => _crashlytics;

  /// Initialize Firebase services
  Future<void> initialize() async {
    try {
      _logger.info('🔥 Initializing Firebase...');

      // Check if Firebase can be initialized (config files exist)
      await Firebase.initializeApp();
      _logger.info('✅ Firebase Core initialized');

      // Initialize Analytics
      await _initializeAnalytics();

      // Initialize Crashlytics
      await _initializeCrashlytics();

      _logger.info('🎉 Firebase services initialized successfully');
    } catch (e, stackTrace) {
      _logger.error('❌ Firebase initialization failed', e, stackTrace);
      rethrow;
    }
  }

  /// Initialize Firebase Analytics
  Future<void> _initializeAnalytics() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      _logger.info('📊 Firebase Analytics initialized');
    } catch (e) {
      _logger.error('❌ Analytics initialization failed', e);
    }
  }

  /// Initialize Firebase Crashlytics
  Future<void> _initializeCrashlytics() async {
    try {
      _crashlytics = FirebaseCrashlytics.instance;

      // Enable crash collection in debug mode
      if (kDebugMode) {
        await _crashlytics?.setCrashlyticsCollectionEnabled(false);
        _logger.info('🐛 Crashlytics disabled in debug mode');
      } else {
        await _crashlytics?.setCrashlyticsCollectionEnabled(true);
        _logger.info('📱 Crashlytics enabled for production');
      }

      // Handle Flutter framework errors
      FlutterError.onError = (errorDetails) {
        _crashlytics?.recordFlutterFatalError(errorDetails);
        _logger.error(
          'Flutter Error:',
          errorDetails.exception,
          errorDetails.stack,
        );
      };

      // Handle async errors
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics?.recordError(error, stack, fatal: true);
        _logger.error('Platform Error:', error, stack);
        return true;
      };

      _logger.info('💥 Firebase Crashlytics initialized');
    } catch (e) {
      _logger.error('❌ Crashlytics initialization failed', e);
    }
  }

  // ============ ANALYTICS METHODS ============

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
      _logger.info('📊 Screen view logged: $screenName');
    } catch (e) {
      _logger.error('❌ Error logging screen view', e);
    }
  }

  /// Log custom event
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics?.logEvent(
        name: name,
        parameters: parameters?.cast<String, Object>(),
      );
      _logger.info('📊 Event logged: $name');
    } catch (e) {
      _logger.error('❌ Error logging event', e);
    }
  }

  /// Log user action
  Future<void> logUserAction({
    required String action,
    String? category,
    String? label,
    int? value,
    Map<String, dynamic>? additionalParams,
  }) async {
    final parameters = <String, dynamic>{
      if (category != null) 'category': category,
      if (label != null) 'label': label,
      if (value != null) 'value': value,
      if (additionalParams != null) ...additionalParams,
    };

    await logEvent(name: 'user_action_$action', parameters: parameters);
  }

  /// Log movie interaction
  Future<void> logMovieInteraction({
    required String action,
    required String movieId,
    String? movieTitle,
    String? genre,
    Map<String, dynamic>? additionalParams,
  }) async {
    final parameters = <String, dynamic>{
      'movie_id': movieId,
      if (movieTitle != null) 'movie_title': movieTitle,
      if (genre != null) 'genre': genre,
      if (additionalParams != null) ...additionalParams,
    };

    await logEvent(name: 'movie_$action', parameters: parameters);
  }

  /// Log search event
  Future<void> logSearch({
    required String searchTerm,
    int? resultCount,
    String? category,
  }) async {
    await logEvent(
      name: 'search',
      parameters: {
        'search_term': searchTerm,
        if (resultCount != null) 'result_count': resultCount,
        if (category != null) 'category': category,
      },
    );
  }

  /// Set user properties
  Future<void> setUserProperties({
    String? userId,
    String? userType,
    String? preferredLanguage,
    String? preferredTheme,
  }) async {
    try {
      if (userId != null) {
        await _analytics?.setUserId(id: userId);
      }

      if (userType != null) {
        await _analytics?.setUserProperty(name: 'user_type', value: userType);
      }

      if (preferredLanguage != null) {
        await _analytics?.setUserProperty(
          name: 'preferred_language',
          value: preferredLanguage,
        );
      }

      if (preferredTheme != null) {
        await _analytics?.setUserProperty(
          name: 'preferred_theme',
          value: preferredTheme,
        );
      }

      _logger.info('👤 User properties set');
    } catch (e) {
      _logger.error('❌ Error setting user properties', e);
    }
  }

  // ============ CRASHLYTICS METHODS ============

  /// Log non-fatal error
  Future<void> logError({
    required dynamic error,
    StackTrace? stackTrace,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics?.recordError(error, stackTrace, fatal: fatal);

      _logger.error('💥 Error logged to Crashlytics', error, stackTrace);
    } catch (e) {
      _logger.error('❌ Error logging to Crashlytics', e);
    }
  }

  /// Set user identifier
  Future<void> setCrashlyticsUserId(String userId) async {
    try {
      await _crashlytics?.setUserIdentifier(userId);
      _logger.info('👤 Crashlytics user ID set: $userId');
    } catch (e) {
      _logger.error('❌ Error setting Crashlytics user ID', e);
    }
  }

  /// Set custom key for crash reports
  Future<void> setCrashlyticsCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics?.setCustomKey(key, value);
    } catch (e) {
      _logger.error('❌ Error setting Crashlytics custom key', e);
    }
  }

  /// Log message to Crashlytics
  Future<void> logMessage(String message) async {
    try {
      await _crashlytics?.log(message);
      _logger.info('📝 Message logged to Crashlytics: $message');
    } catch (e) {
      _logger.error('❌ Error logging message to Crashlytics', e);
    }
  }

  /// Test crash (debug only)
  Future<void> testCrash() async {
    if (kDebugMode) {
      _logger.warning('💥 Testing crash (debug mode)');
      _crashlytics?.crash();
    }
  }

  // ============ UTILITY METHODS ============

  /// Check if Firebase is initialized
  bool get isInitialized {
    return Firebase.apps.isNotEmpty;
  }

  /// Get debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'firebaseInitialized': isInitialized,
      'analyticsEnabled': _analytics != null,
      'crashlyticsEnabled': _crashlytics != null,
      'isDebugMode': kDebugMode,
      'crashlyticsCollectionEnabled': !kDebugMode,
    };
  }

  /// Dispose resources
  void dispose() {
    _analytics = null;
    _crashlytics = null;
    _logger.info('🔥 Firebase service disposed');
  }
}
