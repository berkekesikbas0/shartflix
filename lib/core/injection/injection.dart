import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/event_bus_service.dart';
import '../../features/auth/data/datasources/auth_api_service.dart';
import '../../features/movies/data/datasources/movies_api_service.dart';
import '../../features/movies/domain/repositories/movies_repository.dart';
import '../../features/profile/data/datasources/profile_api_service.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // Register external dependencies
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  // Register Auth API Service with Dio
  getIt.registerFactory<AuthApiService>(
    () => AuthApiService(getIt<ApiService>().dio),
  );

  // Register Movies API Service with Dio
  getIt.registerFactory<MoviesApiService>(
    () => MoviesApiService(getIt<ApiService>().dio),
  );

  // Register Profile API Service with Dio
  getIt.registerFactory<ProfileApiService>(
    () => ProfileApiService(getIt<ApiService>().dio),
  );

  // Register Profile Repository
  getIt.registerFactory<ProfileRepositoryImpl>(
    () => ProfileRepositoryImpl(getIt<ApiService>(), getIt<MoviesRepository>()),
  );

  // Initialize generated dependencies
  getIt.init();
}
