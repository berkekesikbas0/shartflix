import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';
import '../services/logger_service.dart';
import '../services/navigation_service.dart';
import '../theme/app_theme.dart';
import '../injection/injection.dart';
import '../storage/storage_strategy.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/profile_photo_upload_page.dart';
import '../../features/main/presentation/pages/main_wrapper_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

@singleton
class AppRouter {
  final LoggerService _logger;

  AppRouter(this._logger);

  /// Generate routes based on route settings
  Route<dynamic>? generateRoute(RouteSettings settings) {
    _logger.logNavigation('Route Generator', settings.name ?? 'Unknown');

    switch (settings.name) {
      case AppRoutes.splash:
        return _createRoute(const SplashPage());

      case AppRoutes.home:
        return _createRoute(_createAuthCheckWrapper());

      case AppRoutes.auth:
        return _createRoute(const LoginPage());

      case AppRoutes.register:
        return _createRoute(const RegisterPage());

      case AppRoutes.profilePhotoUpload:
        return _createRoute(const ProfilePhotoUploadPage());

      case AppRoutes.profile:
        return _createRoute(const ProfilePage());

      case AppRoutes.settings:
        return _createRoute(_createPlaceholderPage('Settings'));

      default:
        return _createRoute(_createNotFoundPage());
    }
  }

  /// Create route with fade transition
  Route<dynamic> _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppConstants.animationDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return FadeTransition(
          opacity: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  /// Create placeholder page for development
  Widget _createPlaceholderPage(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              '$title Page',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Under Development',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final navigationService = getIt<NavigationService>();
                navigationService.goBack();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  /// Create auth check wrapper for home
  Widget _createAuthCheckWrapper() {
    return FutureBuilder<bool>(
      future: _checkAuthentication(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.netflixRed),
            ),
          );
        }

        if (snapshot.data == true) {
          return const MainWrapperPage();
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final navigationService = getIt<NavigationService>();
            navigationService.navigateToAuth();
          });
          return const SizedBox.shrink();
        }
      },
    );
  }

  /// Check if user is authenticated
  Future<bool> _checkAuthentication() async {
    try {
      final storageManager = getIt<StorageManager>();
      final isAuthenticated = await storageManager.isAuthenticated();
      final token = await storageManager.getAuthToken();

      return isAuthenticated && token != null && token.isNotEmpty;
    } catch (e) {
      _logger.error('Auth check failed', e);
      return false;
    }
  }

  /// Create 404 page
  Widget _createNotFoundPage() {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              '404',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Page Not Found',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final navigationService = getIt<NavigationService>();
                navigationService.navigateToHome();
              },
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String auth = '/auth';
  static const String register = '/register';
  static const String profilePhotoUpload = '/profile-photo-upload';
  static const String movieDetail = '/movie-detail';
  static const String profile = '/profile';
  static const String settings = '/settings';
}
