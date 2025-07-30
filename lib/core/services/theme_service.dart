import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import 'logger_service.dart';

enum AppThemeMode {
  light('light', 'Light Theme', '☀️'),
  dark('dark', 'Dark Theme', '🌙'),
  system('system', 'System Theme', '⚙️');

  const AppThemeMode(this.value, this.displayName, this.icon);

  final String value;
  final String displayName;
  final String icon;
}

@singleton
class ThemeService extends ChangeNotifier {
  final SharedPreferences _prefs;
  final LoggerService _logger;

  ThemeService(this._prefs, this._logger) {
    _loadSavedTheme();
  }

  AppThemeMode _currentThemeMode = AppThemeMode.system;
  Brightness _systemBrightness = Brightness.light;

  /// Get current theme mode
  AppThemeMode get currentThemeMode => _currentThemeMode;

  /// Get current theme data
  ThemeData get currentTheme {
    switch (getEffectiveThemeMode()) {
      case ThemeMode.light:
        return AppTheme.lightTheme;
      case ThemeMode.dark:
        return AppTheme.darkTheme;
      case ThemeMode.system:
        return _systemBrightness == Brightness.light
            ? AppTheme.lightTheme
            : AppTheme.darkTheme;
    }
  }

  /// Get effective theme mode (resolves system theme)
  ThemeMode getEffectiveThemeMode() {
    switch (_currentThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Check if current theme is dark
  bool get isDarkMode {
    switch (_currentThemeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return _systemBrightness == Brightness.dark;
    }
  }

  /// Check if current theme is light
  bool get isLightMode => !isDarkMode;

  /// Change theme mode
  Future<void> changeThemeMode(AppThemeMode mode) async {
    if (_currentThemeMode == mode) return;

    _logger.info(
      '🎨 Changing theme from ${_currentThemeMode.displayName} to ${mode.displayName}',
    );

    _currentThemeMode = mode;
    await _saveTheme(mode);
    notifyListeners();

    _logger.info('✅ Theme changed successfully to ${mode.displayName}');
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_currentThemeMode == AppThemeMode.system) {
      // If system mode, switch to opposite of current system brightness
      await changeThemeMode(
        _systemBrightness == Brightness.light
            ? AppThemeMode.dark
            : AppThemeMode.light,
      );
    } else {
      // Toggle between light and dark
      await changeThemeMode(
        _currentThemeMode == AppThemeMode.light
            ? AppThemeMode.dark
            : AppThemeMode.light,
      );
    }
  }

  /// Set theme to light
  Future<void> setLightTheme() async {
    await changeThemeMode(AppThemeMode.light);
  }

  /// Set theme to dark
  Future<void> setDarkTheme() async {
    await changeThemeMode(AppThemeMode.dark);
  }

  /// Set theme to system
  Future<void> setSystemTheme() async {
    await changeThemeMode(AppThemeMode.system);
  }

  /// Update system brightness (called when system theme changes)
  void updateSystemBrightness(Brightness brightness) {
    if (_systemBrightness != brightness) {
      _logger.info('🌓 System brightness changed to ${brightness.name}');
      _systemBrightness = brightness;

      // Only notify if we're in system mode
      if (_currentThemeMode == AppThemeMode.system) {
        notifyListeners();
      }
    }
  }

  /// Get all available theme modes
  List<AppThemeMode> get availableThemeModes => AppThemeMode.values;

  /// Get theme mode display name
  String getThemeModeDisplayName(AppThemeMode mode) {
    return mode.displayName;
  }

  /// Get theme mode icon
  String getThemeModeIcon(AppThemeMode mode) {
    return mode.icon;
  }

  /// Get current brightness for status bar
  Brightness get statusBarBrightness {
    return isDarkMode ? Brightness.light : Brightness.dark;
  }

  /// Get current navigation bar color
  Color get navigationBarColor {
    return isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight;
  }

  /// Get current system overlay style
  SystemUiOverlayStyle get systemUiOverlayStyle {
    return isDarkMode
        ? SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: AppColors.surfaceDark,
          systemNavigationBarIconBrightness: Brightness.light,
        )
        : SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarColor: AppColors.surfaceLight,
          systemNavigationBarIconBrightness: Brightness.dark,
        );
  }

  /// Load saved theme from SharedPreferences
  Future<void> _loadSavedTheme() async {
    try {
      final savedThemeValue = _prefs.getString(AppConstants.themeKey);

      if (savedThemeValue != null) {
        final savedTheme = AppThemeMode.values.firstWhere(
          (mode) => mode.value == savedThemeValue,
          orElse: () => AppThemeMode.system,
        );

        _currentThemeMode = savedTheme;
        _logger.info('🎨 Loaded saved theme: ${savedTheme.displayName}');
      } else {
        _currentThemeMode = AppThemeMode.system;
        await _saveTheme(_currentThemeMode);
        _logger.info('🎨 No saved theme found, using system theme');
      }
    } catch (e) {
      _logger.error('❌ Error loading saved theme', e);
      _currentThemeMode = AppThemeMode.system;
    }
  }

  /// Save theme to SharedPreferences
  Future<void> _saveTheme(AppThemeMode mode) async {
    try {
      await _prefs.setString(AppConstants.themeKey, mode.value);
      _logger.info('💾 Theme saved: ${mode.displayName}');
    } catch (e) {
      _logger.error('❌ Error saving theme', e);
    }
  }

  /// Get theme colors based on current theme
  AppColors get colors => AppColors();

  /// Get current primary color
  Color get primaryColor {
    return isDarkMode ? AppColors.primaryLight : AppColors.primary;
  }

  /// Get current background color
  Color get backgroundColor {
    return isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight;
  }

  /// Get current surface color
  Color get surfaceColor {
    return isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight;
  }

  /// Get current text color
  Color get textColor {
    return isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary;
  }

  /// Get current secondary text color
  Color get secondaryTextColor {
    return isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;
  }

  /// Debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'currentThemeMode': _currentThemeMode.displayName,
      'effectiveThemeMode': getEffectiveThemeMode().toString(),
      'isDarkMode': isDarkMode,
      'systemBrightness': _systemBrightness.toString(),
      'availableThemes': availableThemeModes.map((t) => t.displayName).toList(),
    };
  }

  /// Reset theme to default (system)
  Future<void> resetToDefault() async {
    await changeThemeMode(AppThemeMode.system);
  }
}
