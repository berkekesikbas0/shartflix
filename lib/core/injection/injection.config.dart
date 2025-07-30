// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_api_service.dart' as _i156;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i17;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/movies/data/datasources/movies_api_service.dart'
    as _i332;
import '../../features/movies/data/repositories/movies_repository_impl.dart'
    as _i985;
import '../../features/movies/domain/repositories/movies_repository.dart'
    as _i435;
import '../../features/movies/domain/usecases/get_favorite_movies_usecase.dart'
    as _i517;
import '../../features/movies/domain/usecases/get_movies_usecase.dart' as _i409;
import '../../features/movies/domain/usecases/toggle_movie_favorite_usecase.dart'
    as _i1018;
import '../../features/movies/presentation/bloc/movies_bloc.dart' as _i169;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/domain/usecases/get_user_profile_usecase.dart'
    as _i146;
import '../../features/profile/domain/usecases/update_profile_photo_usecase.dart'
    as _i669;
import '../../features/profile/domain/usecases/upload_profile_photo_usecase.dart'
    as _i766;
import '../../features/profile/presentation/bloc/profile_bloc.dart' as _i469;
import '../presentation/bloc/localization/localization_bloc.dart' as _i174;
import '../presentation/bloc/theme/theme_bloc.dart' as _i0;
import '../routing/app_router.dart' as _i282;
import '../services/api_service.dart' as _i137;
import '../services/event_bus_service.dart' as _i136;
import '../services/favorite_movies_stream_service.dart' as _i92;
import '../services/firebase_service.dart' as _i758;
import '../services/localization_service.dart' as _i999;
import '../services/logger_service.dart' as _i141;
import '../services/navigation_service.dart' as _i31;
import '../services/secure_storage_service.dart' as _i535;
import '../services/theme_service.dart' as _i982;
import '../storage/storage_strategy.dart' as _i551;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.singleton<_i92.FavoriteMoviesStreamService>(
        () => _i92.FavoriteMoviesStreamService());
    gh.singleton<_i136.EventBusService>(() => _i136.EventBusService());
    gh.singleton<_i141.LoggerService>(() => _i141.LoggerService());
    gh.singleton<_i999.LocalizationService>(() => _i999.LocalizationService(
          gh<_i460.SharedPreferences>(),
          gh<_i141.LoggerService>(),
        ));
    gh.singleton<_i982.ThemeService>(() => _i982.ThemeService(
          gh<_i460.SharedPreferences>(),
          gh<_i141.LoggerService>(),
        ));
    gh.factory<_i551.PreferencesStorageStrategy>(
        () => _i551.PreferencesStorageStrategy(
              gh<_i460.SharedPreferences>(),
              gh<_i141.LoggerService>(),
            ));
    gh.singleton<_i0.ThemeBloc>(() => _i0.ThemeBloc(
          gh<_i982.ThemeService>(),
          gh<_i141.LoggerService>(),
        ));
    gh.singleton<_i282.AppRouter>(
        () => _i282.AppRouter(gh<_i141.LoggerService>()));
    gh.singleton<_i31.NavigationService>(
        () => _i31.NavigationService(gh<_i141.LoggerService>()));
    gh.singleton<_i758.FirebaseService>(
        () => _i758.FirebaseService(gh<_i141.LoggerService>()));
    gh.singleton<_i535.SecureStorageService>(
        () => _i535.SecureStorageService(gh<_i141.LoggerService>()));
    gh.factory<_i551.SecureStorageStrategy>(() => _i551.SecureStorageStrategy(
          gh<_i535.SecureStorageService>(),
          gh<_i141.LoggerService>(),
        ));
    gh.singleton<_i174.LocalizationBloc>(() => _i174.LocalizationBloc(
          gh<_i999.LocalizationService>(),
          gh<_i141.LoggerService>(),
        ));
    gh.singleton<_i551.StorageManager>(() => _i551.StorageManager(
          gh<_i551.SecureStorageStrategy>(),
          gh<_i551.PreferencesStorageStrategy>(),
          gh<_i141.LoggerService>(),
        ));
    gh.lazySingleton<_i435.MoviesRepository>(() => _i985.MoviesRepositoryImpl(
          gh<_i332.MoviesApiService>(),
          gh<_i551.StorageManager>(),
        ));
    gh.lazySingleton<_i787.AuthRepository>(() => _i153.AuthRepositoryImpl(
          gh<_i156.AuthApiService>(),
          gh<_i551.StorageManager>(),
          gh<_i141.LoggerService>(),
        ));
    gh.factory<_i1018.ToggleMovieFavoriteUseCase>(
        () => _i1018.ToggleMovieFavoriteUseCase(gh<_i435.MoviesRepository>()));
    gh.factory<_i517.GetFavoriteMoviesUseCase>(
        () => _i517.GetFavoriteMoviesUseCase(gh<_i435.MoviesRepository>()));
    gh.factory<_i409.GetMoviesUseCase>(
        () => _i409.GetMoviesUseCase(gh<_i435.MoviesRepository>()));
    gh.singleton<_i137.ApiService>(() => _i137.ApiService(
          gh<_i551.StorageManager>(),
          gh<_i141.LoggerService>(),
        ));
    gh.factory<_i941.RegisterUseCase>(
        () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i188.LoginUseCase>(
        () => _i188.LoginUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i48.LogoutUseCase>(
        () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i17.GetCurrentUserUseCase>(
        () => _i17.GetCurrentUserUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i169.MoviesBloc>(() => _i169.MoviesBloc(
          gh<_i409.GetMoviesUseCase>(),
          gh<_i517.GetFavoriteMoviesUseCase>(),
          gh<_i1018.ToggleMovieFavoriteUseCase>(),
          gh<_i136.EventBusService>(),
          gh<_i92.FavoriteMoviesStreamService>(),
        ));
    gh.factory<_i894.ProfileRepository>(() => _i334.ProfileRepositoryImpl(
          gh<_i137.ApiService>(),
          gh<_i435.MoviesRepository>(),
        ));
    gh.factory<_i146.GetUserProfileUseCase>(
        () => _i146.GetUserProfileUseCase(gh<_i894.ProfileRepository>()));
    gh.factory<_i669.UpdateProfilePhotoUseCase>(
        () => _i669.UpdateProfilePhotoUseCase(gh<_i894.ProfileRepository>()));
    gh.singleton<_i797.AuthBloc>(() => _i797.AuthBloc(
          gh<_i141.LoggerService>(),
          gh<_i188.LoginUseCase>(),
          gh<_i941.RegisterUseCase>(),
          gh<_i48.LogoutUseCase>(),
          gh<_i17.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i766.UploadProfilePhotoUseCase>(
        () => _i766.UploadProfilePhotoUseCase(gh<_i894.ProfileRepository>()));
    gh.factory<_i469.ProfileBloc>(() => _i469.ProfileBloc(
          gh<_i146.GetUserProfileUseCase>(),
          gh<_i669.UpdateProfilePhotoUseCase>(),
          gh<_i766.UploadProfilePhotoUseCase>(),
          gh<_i136.EventBusService>(),
          gh<_i92.FavoriteMoviesStreamService>(),
        ));
    return this;
  }
}
