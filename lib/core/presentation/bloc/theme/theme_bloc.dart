import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../services/theme_service.dart';
import '../../../services/logger_service.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class LoadThemeEvent extends ThemeEvent {
  const LoadThemeEvent();
}

class ChangeThemeModeEvent extends ThemeEvent {
  final AppThemeMode themeMode;

  const ChangeThemeModeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class ToggleThemeEvent extends ThemeEvent {
  const ToggleThemeEvent();
}

class UpdateSystemBrightnessEvent extends ThemeEvent {
  final Brightness brightness;

  const UpdateSystemBrightnessEvent(this.brightness);

  @override
  List<Object?> get props => [brightness];
}

class ResetThemeEvent extends ThemeEvent {
  const ResetThemeEvent();
}

// States
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {
  const ThemeInitial();
}

class ThemeLoading extends ThemeState {
  const ThemeLoading();
}

class ThemeLoaded extends ThemeState {
  final AppThemeMode currentThemeMode;
  final bool isDarkMode;
  final ThemeData themeData;
  final List<AppThemeMode> availableThemes;

  const ThemeLoaded({
    required this.currentThemeMode,
    required this.isDarkMode,
    required this.themeData,
    required this.availableThemes,
  });

  @override
  List<Object?> get props => [
    currentThemeMode,
    isDarkMode,
    themeData,
    availableThemes,
  ];

  ThemeLoaded copyWith({
    AppThemeMode? currentThemeMode,
    bool? isDarkMode,
    ThemeData? themeData,
    List<AppThemeMode>? availableThemes,
  }) {
    return ThemeLoaded(
      currentThemeMode: currentThemeMode ?? this.currentThemeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themeData: themeData ?? this.themeData,
      availableThemes: availableThemes ?? this.availableThemes,
    );
  }
}

class ThemeError extends ThemeState {
  final String message;

  const ThemeError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
@singleton
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeService _themeService;
  final LoggerService _logger;

  ThemeBloc(this._themeService, this._logger) : super(const ThemeInitial()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ChangeThemeModeEvent>(_onChangeThemeMode);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<UpdateSystemBrightnessEvent>(_onUpdateSystemBrightness);
    on<ResetThemeEvent>(_onResetTheme);

    // Load initial theme
    add(const LoadThemeEvent());
  }

  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      emit(const ThemeLoading());

      final currentThemeMode = _themeService.currentThemeMode;
      final isDarkMode = _themeService.isDarkMode;
      final themeData = _themeService.currentTheme;
      final availableThemes = _themeService.availableThemeModes;

      emit(
        ThemeLoaded(
          currentThemeMode: currentThemeMode,
          isDarkMode: isDarkMode,
          themeData: themeData,
          availableThemes: availableThemes,
        ),
      );

      _logger.info('🎨 Theme loaded: ${currentThemeMode.displayName}');
    } catch (e) {
      _logger.error('❌ Error loading theme', e);
      emit(ThemeError(e.toString()));
    }
  }

  Future<void> _onChangeThemeMode(
    ChangeThemeModeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      if (state is ThemeLoaded) {
        final currentState = state as ThemeLoaded;

        if (currentState.currentThemeMode == event.themeMode) {
          _logger.info(
            '🎨 Theme mode already selected: ${event.themeMode.displayName}',
          );
          return;
        }

        emit(const ThemeLoading());

        await _themeService.changeThemeMode(event.themeMode);

        emit(
          currentState.copyWith(
            currentThemeMode: event.themeMode,
            isDarkMode: _themeService.isDarkMode,
            themeData: _themeService.currentTheme,
          ),
        );

        _logger.info('🎨 Theme changed to: ${event.themeMode.displayName}');
      }
    } catch (e) {
      _logger.error('❌ Error changing theme mode', e);
      emit(ThemeError(e.toString()));
    }
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      if (state is ThemeLoaded) {
        final currentState = state as ThemeLoaded;

        emit(const ThemeLoading());

        await _themeService.toggleTheme();

        emit(
          currentState.copyWith(
            currentThemeMode: _themeService.currentThemeMode,
            isDarkMode: _themeService.isDarkMode,
            themeData: _themeService.currentTheme,
          ),
        );

        _logger.info(
          '🔄 Theme toggled to: ${_themeService.currentThemeMode.displayName}',
        );
      }
    } catch (e) {
      _logger.error('❌ Error toggling theme', e);
      emit(ThemeError(e.toString()));
    }
  }

  Future<void> _onUpdateSystemBrightness(
    UpdateSystemBrightnessEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      if (state is ThemeLoaded) {
        final currentState = state as ThemeLoaded;

        _themeService.updateSystemBrightness(event.brightness);

        // Only emit new state if we're in system mode
        if (currentState.currentThemeMode == AppThemeMode.system) {
          emit(
            currentState.copyWith(
              isDarkMode: _themeService.isDarkMode,
              themeData: _themeService.currentTheme,
            ),
          );

          _logger.info(
            '🌓 System brightness updated: ${event.brightness.name}',
          );
        }
      }
    } catch (e) {
      _logger.error('❌ Error updating system brightness', e);
      emit(ThemeError(e.toString()));
    }
  }

  Future<void> _onResetTheme(
    ResetThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      if (state is ThemeLoaded) {
        final currentState = state as ThemeLoaded;

        emit(const ThemeLoading());

        await _themeService.resetToDefault();

        emit(
          currentState.copyWith(
            currentThemeMode: _themeService.currentThemeMode,
            isDarkMode: _themeService.isDarkMode,
            themeData: _themeService.currentTheme,
          ),
        );

        _logger.info(
          '🔄 Theme reset to default: ${_themeService.currentThemeMode.displayName}',
        );
      }
    } catch (e) {
      _logger.error('❌ Error resetting theme', e);
      emit(ThemeError(e.toString()));
    }
  }

  // Getters for easy access
  AppThemeMode? get currentThemeMode {
    if (state is ThemeLoaded) {
      return (state as ThemeLoaded).currentThemeMode;
    }
    return null;
  }

  bool get isDarkMode {
    if (state is ThemeLoaded) {
      return (state as ThemeLoaded).isDarkMode;
    }
    return false;
  }

  ThemeData? get themeData {
    if (state is ThemeLoaded) {
      return (state as ThemeLoaded).themeData;
    }
    return null;
  }

  List<AppThemeMode> get availableThemes {
    if (state is ThemeLoaded) {
      return (state as ThemeLoaded).availableThemes;
    }
    return AppThemeMode.values;
  }

  bool get isLoading => state is ThemeLoading;
  bool get hasError => state is ThemeError;
  String? get errorMessage {
    if (state is ThemeError) {
      return (state as ThemeError).message;
    }
    return null;
  }

  ThemeMode get effectiveThemeMode {
    if (state is ThemeLoaded) {
      return _themeService.getEffectiveThemeMode();
    }
    return ThemeMode.system;
  }
}
