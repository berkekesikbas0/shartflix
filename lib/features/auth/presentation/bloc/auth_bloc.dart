import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_token_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginEvent({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [name, email, password, confirmPassword];
}

class SocialLoginEvent extends AuthEvent {
  final SocialLoginType type;

  const SocialLoginEvent(this.type);

  @override
  List<Object?> get props => [type];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class RefreshUserDataEvent extends AuthEvent {
  const RefreshUserDataEvent();
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent(this.email);

  @override
  List<Object?> get props => [email];
}

enum SocialLoginType { google, apple, facebook }

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  final AuthTokenEntity? token;

  const AuthAuthenticated(this.user, [this.token]);

  @override
  List<Object?> get props => [user, token];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final Map<String, List<String>>? validationErrors;

  const AuthError(this.message, [this.validationErrors]);

  @override
  List<Object?> get props => [message, validationErrors];
}

class AuthSuccess extends AuthState {
  final String message;

  const AuthSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoggerService _logger;
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthBloc(
    this._logger,
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
  ) : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<SocialLoginEvent>(_onSocialLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<RefreshUserDataEvent>(_onRefreshUserData);
    on<ForgotPasswordEvent>(_onForgotPassword);

    // Check auth status on init
    add(const CheckAuthStatusEvent());
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthLoading());

      _logger.info('🔐 Attempting login for email: ${event.email}');

      final result = await _loginUseCase.call(
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
      );

      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => null)!;
        _logger.error('❌ Login failed: ${failure.message}');

        if (failure is ValidationFailure) {
          emit(AuthError(failure.message, failure.errors));
        } else {
          emit(AuthError(failure.message));
        }
      } else {
        final token = result.fold((l) => null, (r) => r)!;
        _logger.info('✅ Login successful');

        // Get user data from storage (it was just stored by repository)
        final cachedUser = await _getCurrentUserUseCase.getCachedUser();
        if (cachedUser != null) {
          emit(AuthAuthenticated(cachedUser, token));
        } else {
          // Fallback: create user entity from login data
          final userEntity = UserEntity(
            id: 'temp_id',
            name: 'User',
            email: event.email,
            phoneNumber: null,
            profileImageUrl: null,
            emailVerifiedAt: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          emit(AuthAuthenticated(userEntity, token));
        }
      }
    } catch (e) {
      _logger.error('❌ Login unexpected error', e);
      emit(AuthError('Beklenmeyen bir hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthLoading());

      _logger.info('📝 Attempting registration for email: ${event.email}');

      final result = await _registerUseCase.call(
        name: event.name,
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
      );

      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => null)!;
        _logger.error('❌ Registration failed: ${failure.message}');

        if (failure is ValidationFailure) {
          emit(AuthError(failure.message, failure.errors));
        } else {
          emit(AuthError(failure.message));
        }
      } else {
        final token = result.fold((l) => null, (r) => r)!;
        _logger.info('✅ Registration successful');

        // Create user entity from the registration response
        // We already have user data from the registration response
        final userEntity = UserEntity(
          id: 'temp_id', // Will be updated when we get profile
          name: event.name,
          email: event.email,
          phoneNumber: null,
          profileImageUrl: null,
          emailVerifiedAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        emit(AuthAuthenticated(userEntity, token));
      }
    } catch (e) {
      _logger.error('❌ Registration unexpected error', e);
      emit(AuthError('Beklenmeyen bir hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> _onSocialLogin(
    SocialLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      _logger.info('🔗 Attempting ${event.type.name} login');

      // TODO: Implement social login when available
      await Future.delayed(const Duration(seconds: 1));

      emit(const AuthError('Sosyal medya girişi henüz desteklenmiyor'));
    } catch (e) {
      _logger.error('❌ Social login failed', e);
      emit(AuthError('${event.type.name} ile giriş yapılırken hata oluştu'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthLoading());

      _logger.info('👋 Attempting logout');

      final result = await _logoutUseCase.call();

      result.fold(
        (failure) {
          _logger.error('❌ Logout failed: ${failure.message}');
          // Even if logout fails, clear local state
          emit(const AuthUnauthenticated());
        },
        (_) {
          _logger.info('✅ Logout successful');
          emit(const AuthUnauthenticated());
        },
      );
    } catch (e) {
      _logger.error('❌ Logout error', e);
      // Always clear auth state on logout
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      _logger.info('🔍 Checking auth status');

      final isAuthenticated = await _getCurrentUserUseCase.isAuthenticated();

      if (isAuthenticated) {
        // Try to get cached user first
        final cachedUser = await _getCurrentUserUseCase.getCachedUser();

        if (cachedUser != null) {
          emit(AuthAuthenticated(cachedUser));
          _logger.info('✅ User is authenticated (from cache)');
        } else {
          // Fallback to API call
          final result = await _getCurrentUserUseCase.call();
          result.fold(
            (failure) {
              _logger.error('❌ Failed to get user data: ${failure.message}');
              emit(const AuthUnauthenticated());
            },
            (user) {
              emit(AuthAuthenticated(user));
              _logger.info('✅ User is authenticated (from API)');
            },
          );
        }
      } else {
        emit(const AuthUnauthenticated());
        _logger.info('❌ User is not authenticated');
      }
    } catch (e) {
      _logger.error('❌ Error checking auth status', e);
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onRefreshUserData(
    RefreshUserDataEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      _logger.info('🔄 Refreshing user data');

      final result = await _getCurrentUserUseCase.call(forceRefresh: true);

      result.fold(
        (failure) {
          _logger.error('❌ Failed to refresh user data: ${failure.message}');

          if (failure is AuthFailure) {
            // Token might be expired
            emit(const AuthUnauthenticated());
          } else {
            emit(AuthError('Kullanıcı bilgileri güncellenemedi'));
          }
        },
        (user) {
          _logger.info('✅ User data refreshed');
          emit(AuthAuthenticated(user));
        },
      );
    } catch (e) {
      _logger.error('❌ Refresh user data error', e);
      emit(AuthError('Kullanıcı bilgileri güncellenirken hata oluştu'));
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      _logger.info('📧 Sending forgot password email to: ${event.email}');

      // Basic email validation
      if (event.email.trim().isEmpty) {
        emit(const AuthError('E-posta adresi gereklidir'));
        return;
      }

      if (!RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(event.email.trim())) {
        emit(const AuthError('Geçerli bir e-posta adresi giriniz'));
        return;
      }

      // TODO: Implement forgot password API call when available
      await Future.delayed(const Duration(seconds: 2));

      emit(
        const AuthSuccess(
          'Şifre sıfırlama linki e-posta adresinize gönderildi',
        ),
      );
      _logger.info('✅ Password reset email sent');
    } catch (e) {
      _logger.error('❌ Forgot password failed', e);
      emit(const AuthError('Şifre sıfırlarken hata oluştu'));
    }
  }

  // Getters
  bool get isAuthenticated => state is AuthAuthenticated;
  bool get isLoading => state is AuthLoading;
  bool get hasError => state is AuthError;

  String? get errorMessage {
    if (state is AuthError) {
      return (state as AuthError).message;
    }
    return null;
  }

  Map<String, List<String>>? get validationErrors {
    if (state is AuthError) {
      return (state as AuthError).validationErrors;
    }
    return null;
  }

  UserEntity? get currentUser {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).user;
    }
    return null;
  }

  AuthTokenEntity? get currentToken {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).token;
    }
    return null;
  }
}
