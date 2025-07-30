import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';
import 'logger_service.dart';

@singleton
class SecureStorageService {
  final FlutterSecureStorage _storage;
  final LoggerService _logger;

  SecureStorageService(this._logger)
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

  /// Store string value
  Future<void> storeString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      _logger.info('🔐 Stored string with key: $key');
    } catch (e) {
      _logger.error('❌ Error storing string with key: $key', e);
      rethrow;
    }
  }

  /// Get string value
  Future<String?> getString(String key) async {
    try {
      final value = await _storage.read(key: key);
      _logger.info('🔓 Retrieved string with key: $key');
      return value;
    } catch (e) {
      _logger.error('❌ Error retrieving string with key: $key', e);
      return null;
    }
  }

  /// Store object as JSON
  Future<void> storeObject(String key, Map<String, dynamic> object) async {
    try {
      final jsonString = json.encode(object);
      await _storage.write(key: key, value: jsonString);
      _logger.info('🔐 Stored object with key: $key');
    } catch (e) {
      _logger.error('❌ Error storing object with key: $key', e);
      rethrow;
    }
  }

  /// Get object from JSON
  Future<Map<String, dynamic>?> getObject(String key) async {
    try {
      final jsonString = await _storage.read(key: key);
      if (jsonString != null) {
        final object = json.decode(jsonString) as Map<String, dynamic>;
        _logger.info('🔓 Retrieved object with key: $key');
        return object;
      }
      return null;
    } catch (e) {
      _logger.error('❌ Error retrieving object with key: $key', e);
      return null;
    }
  }

  /// Store list as JSON
  Future<void> storeList(String key, List<dynamic> list) async {
    try {
      final jsonString = json.encode(list);
      await _storage.write(key: key, value: jsonString);
      _logger.info('🔐 Stored list with key: $key');
    } catch (e) {
      _logger.error('❌ Error storing list with key: $key', e);
      rethrow;
    }
  }

  /// Get list from JSON
  Future<List<dynamic>?> getList(String key) async {
    try {
      final jsonString = await _storage.read(key: key);
      if (jsonString != null) {
        final list = json.decode(jsonString) as List<dynamic>;
        _logger.info('🔓 Retrieved list with key: $key');
        return list;
      }
      return null;
    } catch (e) {
      _logger.error('❌ Error retrieving list with key: $key', e);
      return null;
    }
  }

  /// Delete specific key
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      _logger.info('🗑️ Deleted key: $key');
    } catch (e) {
      _logger.error('❌ Error deleting key: $key', e);
      rethrow;
    }
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      _logger.info('🧹 Cleared all secure storage');
    } catch (e) {
      _logger.error('❌ Error clearing all secure storage', e);
      rethrow;
    }
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      _logger.error('❌ Error checking key existence: $key', e);
      return false;
    }
  }

  /// Get all keys
  Future<Set<String>> getAllKeys() async {
    try {
      final keys = await _storage.readAll();
      return keys.keys.toSet();
    } catch (e) {
      _logger.error('❌ Error getting all keys', e);
      return <String>{};
    }
  }

  // ============ AUTH TOKEN METHODS ============

  /// Store authentication token
  Future<void> storeAuthToken(String token) async {
    await storeString(AppConstants.tokenKey, token);
    _logger.info('🎫 Auth token stored');
  }

  /// Get authentication token
  Future<String?> getAuthToken() async {
    final token = await getString(AppConstants.tokenKey);
    if (token != null) {
      _logger.info('🎫 Auth token retrieved');
    }
    return token;
  }

  /// Delete authentication token
  Future<void> deleteAuthToken() async {
    await delete(AppConstants.tokenKey);
    _logger.info('🎫 Auth token deleted');
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // ============ USER DATA METHODS ============

  /// Store user data
  Future<void> storeUserData(Map<String, dynamic> userData) async {
    await storeObject(AppConstants.userKey, userData);
    _logger.info('👤 User data stored');
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    final userData = await getObject(AppConstants.userKey);
    if (userData != null) {
      _logger.info('👤 User data retrieved');
    }
    return userData;
  }

  /// Delete user data
  Future<void> deleteUserData() async {
    await delete(AppConstants.userKey);
    _logger.info('👤 User data deleted');
  }

  /// Clear all auth-related data
  Future<void> clearAuthData() async {
    await deleteAuthToken();
    await deleteUserData();
    _logger.info('🧹 All auth data cleared');
  }

  // ============ UTILITY METHODS ============

  /// Store encrypted sensitive data
  Future<void> storeSensitiveData(String key, String data) async {
    try {
      // Additional encryption layer can be added here if needed
      await storeString(key, data);
      _logger.info('🔒 Sensitive data stored with key: $key');
    } catch (e) {
      _logger.error('❌ Error storing sensitive data', e);
      rethrow;
    }
  }

  /// Get decrypted sensitive data
  Future<String?> getSensitiveData(String key) async {
    try {
      // Additional decryption layer can be added here if needed
      final data = await getString(key);
      if (data != null) {
        _logger.info('🔓 Sensitive data retrieved with key: $key');
      }
      return data;
    } catch (e) {
      _logger.error('❌ Error retrieving sensitive data', e);
      return null;
    }
  }

  /// Get storage size info (debug purposes)
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final allKeys = await getAllKeys();
      return {
        'totalKeys': allKeys.length,
        'keys': allKeys.toList(),
        'hasAuthToken': await containsKey(AppConstants.tokenKey),
        'hasUserData': await containsKey(AppConstants.userKey),
      };
    } catch (e) {
      _logger.error('❌ Error getting storage info', e);
      return {};
    }
  }
}
