import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../services/localization_service.dart';
import '../../../services/logger_service.dart';

// Events
abstract class LocalizationEvent extends Equatable {
  const LocalizationEvent();

  @override
  List<Object?> get props => [];
}

class LoadLocalizationEvent extends LocalizationEvent {
  const LoadLocalizationEvent();
}

class ChangeLanguageEvent extends LocalizationEvent {
  final SupportedLanguage language;

  const ChangeLanguageEvent(this.language);

  @override
  List<Object?> get props => [language];
}

class SetToSystemLanguageEvent extends LocalizationEvent {
  const SetToSystemLanguageEvent();
}

class ResetToDefaultEvent extends LocalizationEvent {
  const ResetToDefaultEvent();
}

// States
abstract class LocalizationState extends Equatable {
  const LocalizationState();

  @override
  List<Object?> get props => [];
}

class LocalizationInitial extends LocalizationState {
  const LocalizationInitial();
}

class LocalizationLoading extends LocalizationState {
  const LocalizationLoading();
}

class LocalizationLoaded extends LocalizationState {
  final SupportedLanguage currentLanguage;
  final List<SupportedLanguage> availableLanguages;

  const LocalizationLoaded({
    required this.currentLanguage,
    required this.availableLanguages,
  });

  @override
  List<Object?> get props => [currentLanguage, availableLanguages];

  LocalizationLoaded copyWith({
    SupportedLanguage? currentLanguage,
    List<SupportedLanguage>? availableLanguages,
  }) {
    return LocalizationLoaded(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      availableLanguages: availableLanguages ?? this.availableLanguages,
    );
  }
}

class LocalizationError extends LocalizationState {
  final String message;

  const LocalizationError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
@singleton
class LocalizationBloc extends Bloc<LocalizationEvent, LocalizationState> {
  final LocalizationService _localizationService;
  final LoggerService _logger;

  LocalizationBloc(this._localizationService, this._logger)
    : super(const LocalizationInitial()) {
    on<LoadLocalizationEvent>(_onLoadLocalization);
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<SetToSystemLanguageEvent>(_onSetToSystemLanguage);
    on<ResetToDefaultEvent>(_onResetToDefault);

    // Load initial localization
    add(const LoadLocalizationEvent());
  }

  Future<void> _onLoadLocalization(
    LoadLocalizationEvent event,
    Emitter<LocalizationState> emit,
  ) async {
    try {
      emit(const LocalizationLoading());

      final currentLanguage = _localizationService.currentLanguage;
      final availableLanguages = _localizationService.availableLanguages;

      emit(
        LocalizationLoaded(
          currentLanguage: currentLanguage,
          availableLanguages: availableLanguages,
        ),
      );

      _logger.info('📱 Localization loaded: ${currentLanguage.displayName}');
    } catch (e) {
      _logger.error('❌ Error loading localization', e);
      emit(LocalizationError(e.toString()));
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<LocalizationState> emit,
  ) async {
    try {
      if (state is LocalizationLoaded) {
        final currentState = state as LocalizationLoaded;

        if (currentState.currentLanguage == event.language) {
          _logger.info(
            '🌍 Language already selected: ${event.language.displayName}',
          );
          return;
        }

        emit(const LocalizationLoading());

        await _localizationService.changeLanguage(event.language);

        emit(currentState.copyWith(currentLanguage: event.language));

        _logger.info('🌍 Language changed to: ${event.language.displayName}');
      }
    } catch (e) {
      _logger.error('❌ Error changing language', e);
      emit(LocalizationError(e.toString()));
    }
  }

  Future<void> _onSetToSystemLanguage(
    SetToSystemLanguageEvent event,
    Emitter<LocalizationState> emit,
  ) async {
    try {
      if (state is LocalizationLoaded) {
        final currentState = state as LocalizationLoaded;

        emit(const LocalizationLoading());

        await _localizationService.setToSystemLanguage();
        final systemLanguage = _localizationService.currentLanguage;

        emit(currentState.copyWith(currentLanguage: systemLanguage));

        _logger.info(
          '🔍 Language set to system: ${systemLanguage.displayName}',
        );
      }
    } catch (e) {
      _logger.error('❌ Error setting to system language', e);
      emit(LocalizationError(e.toString()));
    }
  }

  Future<void> _onResetToDefault(
    ResetToDefaultEvent event,
    Emitter<LocalizationState> emit,
  ) async {
    try {
      if (state is LocalizationLoaded) {
        final currentState = state as LocalizationLoaded;

        emit(const LocalizationLoading());

        await _localizationService.resetToDefault();
        final defaultLanguage = _localizationService.currentLanguage;

        emit(currentState.copyWith(currentLanguage: defaultLanguage));

        _logger.info(
          '🔄 Language reset to default: ${defaultLanguage.displayName}',
        );
      }
    } catch (e) {
      _logger.error('❌ Error resetting to default language', e);
      emit(LocalizationError(e.toString()));
    }
  }

  // Getters for easy access
  SupportedLanguage? get currentLanguage {
    if (state is LocalizationLoaded) {
      return (state as LocalizationLoaded).currentLanguage;
    }
    return null;
  }

  List<SupportedLanguage> get availableLanguages {
    if (state is LocalizationLoaded) {
      return (state as LocalizationLoaded).availableLanguages;
    }
    return SupportedLanguage.values;
  }

  bool get isLoading => state is LocalizationLoading;
  bool get hasError => state is LocalizationError;
  String? get errorMessage {
    if (state is LocalizationError) {
      return (state as LocalizationError).message;
    }
    return null;
  }
}
