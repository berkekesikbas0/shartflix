import 'package:injectable/injectable.dart';
import '../services/secure_storage_service.dart';
import '../services/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage strategy interface for different data types
abstract class IStorageStrategy {
  Future<void> store(String key, dynamic value);
  Future<T?> retrieve<T>(String key);
  Future<void> delete(String key);
  Future<void> clear();
  Future<bool> containsKey(String key);
}

/// Secure storage strategy for sensitive data (tokens, user credentials)
@injectable
class SecureStorageStrategy implements IStorageStrategy {
  final SecureStorageService _secureStorage;
  final LoggerService _logger;

  SecureStorageStrategy(this._secureStorage, this._logger);

  @override
  Future<void> store(String key, dynamic value) async {
    try {
      if (value is String) {
        await _secureStorage.storeString(key, value);
      } else if (value is Map<String, dynamic>) {
        await _secureStorage.storeObject(key, value);
      } else if (value is List) {
        await _secureStorage.storeList(key, value);
      } else {
        throw ArgumentError('Unsupported value type: ${value.runtimeType}');
      }
      _logger.info('🔐 Stored in secure storage: $key');
    } catch (e) {
      _logger.error('❌ Error storing in secure storage', e);
      rethrow;
    }
  }

  @override
  Future<T?> retrieve<T>(String key) async {
    try {
      if (T == String) {
        return await _secureStorage.getString(key) as T?;
      } else if (T == Map<String, dynamic>) {
        return await _secureStorage.getObject(key) as T?;
      } else if (T == List) {
        return await _secureStorage.getList(key) as T?;
      } else {
        throw ArgumentError('Unsupported type: $T');
      }
    } catch (e) {
      _logger.error('❌ Error retrieving from secure storage', e);
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    await _secureStorage.delete(key);
  }

  @override
  Future<void> clear() async {
    await _secureStorage.clearAll();
  }

  @override
  Future<bool> containsKey(String key) async {
    return await _secureStorage.containsKey(key);
  }
}

/// Preferences storage strategy for app settings and non-sensitive data
@injectable
class PreferencesStorageStrategy implements IStorageStrategy {
  final SharedPreferences _prefs;
  final LoggerService _logger;

  PreferencesStorageStrategy(this._prefs, this._logger);

  @override
  Future<void> store(String key, dynamic value) async {
    try {
      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is List<String>) {
        await _prefs.setStringList(key, value);
      } else {
        throw ArgumentError('Unsupported value type: ${value.runtimeType}');
      }
      _logger.info('💾 Stored in preferences: $key');
    } catch (e) {
      _logger.error('❌ Error storing in preferences', e);
      rethrow;
    }
  }

  @override
  Future<T?> retrieve<T>(String key) async {
    try {
      final value = _prefs.get(key);
      return value as T?;
    } catch (e) {
      _logger.error('❌ Error retrieving from preferences', e);
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }
}

/// Unified storage manager that routes data to appropriate storage
@singleton
class StorageManager {
  final SecureStorageStrategy _secureStorage;
  final PreferencesStorageStrategy _preferencesStorage;
  final LoggerService _logger;

  StorageManager(this._secureStorage, this._preferencesStorage, this._logger);

  // Sensitive data keys that should use secure storage
  static const Set<String> _sensitiveKeys = {
    'auth_token',
    'refresh_token',
    'user_data',
    'api_key',
    'user_credentials',
    'biometric_data',
  };

  /// Store data using appropriate storage strategy
  Future<void> store(String key, dynamic value) async {
    final strategy = _getStrategy(key);
    await strategy.store(key, value);
  }

  /// Retrieve data using appropriate storage strategy
  Future<T?> retrieve<T>(String key) async {
    final strategy = _getStrategy(key);
    return await strategy.retrieve<T>(key);
  }

  /// Delete data from appropriate storage
  Future<void> delete(String key) async {
    final strategy = _getStrategy(key);
    await strategy.delete(key);
  }

  /// Check if key exists in appropriate storage
  Future<bool> containsKey(String key) async {
    final strategy = _getStrategy(key);
    return await strategy.containsKey(key);
  }

  /// Clear all data from both storages
  Future<void> clearAll() async {
    await _secureStorage.clear();
    await _preferencesStorage.clear();
    _logger.info('🧹 All storage cleared');
  }

  /// Clear only secure storage
  Future<void> clearSecureStorage() async {
    await _secureStorage.clear();
    _logger.info('🔐 Secure storage cleared');
  }

  /// Clear only preferences storage
  Future<void> clearPreferences() async {
    await _preferencesStorage.clear();
    _logger.info('💾 Preferences storage cleared');
  }

  /// Get storage strategy based on key sensitivity
  IStorageStrategy _getStrategy(String key) {
    if (_sensitiveKeys.contains(key) ||
        key.contains('token') ||
        key.contains('password')) {
      return _secureStorage;
    }
    return _preferencesStorage;
  }

  /// Get storage info for debugging
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final secureInfo =
          await _secureStorage.retrieve<Map<String, dynamic>>('storage_info') ??
          {};
      return {
        'secureStorageKeys': secureInfo.keys.toList(),
        'preferencesKeys': _preferencesStorage._prefs.getKeys().toList(),
        'sensitiveKeys': _sensitiveKeys.toList(),
      };
    } catch (e) {
      _logger.error('❌ Error getting storage info', e);
      return {};
    }
  }

  // ============ CONVENIENCE METHODS ============

  /// Store auth token securely
  Future<void> storeAuthToken(String token) async {
    await store('auth_token', token);
  }

  /// Get auth token
  Future<String?> getAuthToken() async {
    return await retrieve<String>('auth_token');
  }

  /// Store user data securely
  Future<void> storeUserData(Map<String, dynamic> userData) async {
    await store('user_data', userData);
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    return await retrieve<Map<String, dynamic>>('user_data');
  }

  /// Store app setting
  Future<void> storeSetting(String key, dynamic value) async {
    await store('setting_$key', value);
  }

  /// Get app setting
  Future<T?> getSetting<T>(String key) async {
    return await retrieve<T>('setting_$key');
  }

  /// Clear all auth-related data
  Future<void> clearAuthData() async {
    await delete('auth_token');
    await delete('refresh_token');
    await delete('user_data');
    _logger.info('🧹 Auth data cleared');
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
}
