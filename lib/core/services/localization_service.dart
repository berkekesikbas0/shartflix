import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'logger_service.dart';

enum SupportedLanguage {
  turkish('tr', 'TR', 'Türkçe'),
  english('en', 'US', 'English');

  const SupportedLanguage(
    this.languageCode,
    this.countryCode,
    this.displayName,
  );

  final String languageCode;
  final String countryCode;
  final String displayName;

  Locale get locale => Locale(languageCode, countryCode);
}

@singleton
class LocalizationService extends ChangeNotifier {
  final SharedPreferences _prefs;
  final LoggerService _logger;

  LocalizationService(this._prefs, this._logger) {
    _loadSavedLanguage();
  }

  SupportedLanguage _currentLanguage = SupportedLanguage.turkish;

  /// Get current language
  SupportedLanguage get currentLanguage => _currentLanguage;

  /// Get current locale
  Locale get currentLocale => _currentLanguage.locale;

  /// Get supported locales
  List<Locale> get supportedLocales =>
      SupportedLanguage.values.map((lang) => lang.locale).toList();

  /// Check if language is supported
  bool isLanguageSupported(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  /// Change app language
  Future<void> changeLanguage(SupportedLanguage language) async {
    if (_currentLanguage == language) return;

    _logger.info(
      '🌍 Changing language from ${_currentLanguage.displayName} to ${language.displayName}',
    );

    _currentLanguage = language;
    await _saveLanguage(language);
    notifyListeners();

    _logger.info('✅ Language changed successfully to ${language.displayName}');
  }

  /// Get language from locale
  SupportedLanguage? getLanguageFromLocale(Locale locale) {
    try {
      return SupportedLanguage.values.firstWhere(
        (lang) => lang.languageCode == locale.languageCode,
      );
    } catch (e) {
      _logger.warning('Language not found for locale: ${locale.languageCode}');
      return null;
    }
  }

  /// Get system language
  SupportedLanguage getSystemLanguage() {
    final systemLocale = PlatformDispatcher.instance.locale;
    final systemLanguage = getLanguageFromLocale(systemLocale);

    if (systemLanguage != null) {
      _logger.info(
        '🔍 System language detected: ${systemLanguage.displayName}',
      );
      return systemLanguage;
    }

    _logger.info('🔍 System language not supported, defaulting to Turkish');
    return SupportedLanguage.turkish;
  }

  /// Set language to system default
  Future<void> setToSystemLanguage() async {
    final systemLanguage = getSystemLanguage();
    await changeLanguage(systemLanguage);
  }

  /// Reset to default language (Turkish)
  Future<void> resetToDefault() async {
    await changeLanguage(SupportedLanguage.turkish);
  }

  /// Get language display name
  String getLanguageDisplayName(SupportedLanguage language) {
    return language.displayName;
  }

  /// Get all available languages
  List<SupportedLanguage> get availableLanguages => SupportedLanguage.values;

  /// Check if current language is RTL (Right-to-Left)
  bool get isRTL {
    // Turkish and English are LTR languages
    // Add RTL languages here if needed in the future
    return false;
  }

  /// Get text direction
  TextDirection get textDirection =>
      isRTL ? TextDirection.rtl : TextDirection.ltr;

  /// Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    try {
      final savedLanguageCode = _prefs.getString(AppConstants.languageKey);

      if (savedLanguageCode != null) {
        final savedLanguage = SupportedLanguage.values.firstWhere(
          (lang) => lang.languageCode == savedLanguageCode,
          orElse: () => SupportedLanguage.turkish,
        );

        _currentLanguage = savedLanguage;
        _logger.info('📱 Loaded saved language: ${savedLanguage.displayName}');
      } else {
        _currentLanguage = getSystemLanguage();
        await _saveLanguage(_currentLanguage);
        _logger.info(
          '📱 No saved language found, using system language: ${_currentLanguage.displayName}',
        );
      }
    } catch (e) {
      _logger.error('❌ Error loading saved language', e);
      _currentLanguage = SupportedLanguage.turkish;
    }
  }

  /// Save language to SharedPreferences
  Future<void> _saveLanguage(SupportedLanguage language) async {
    try {
      await _prefs.setString(AppConstants.languageKey, language.languageCode);
      _logger.info('💾 Language saved: ${language.displayName}');
    } catch (e) {
      _logger.error('❌ Error saving language', e);
    }
  }

  /// Get language flag emoji
  String getLanguageFlag(SupportedLanguage language) {
    switch (language) {
      case SupportedLanguage.turkish:
        return '🇹🇷';
      case SupportedLanguage.english:
        return '🇺🇸';
    }
  }

  /// Debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'currentLanguage': _currentLanguage.displayName,
      'currentLocale': currentLocale.toString(),
      'isRTL': isRTL,
      'textDirection': textDirection.toString(),
      'supportedLanguages':
          availableLanguages.map((l) => l.displayName).toList(),
    };
  }
}
