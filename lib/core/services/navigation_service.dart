import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:go_router/go_router.dart';
import '../routing/app_router.dart';
import 'logger_service.dart';

@singleton
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  final LoggerService _logger;

  NavigationService(this._logger);

  /// Get current context
  BuildContext? get currentContext => navigatorKey.currentContext;

  /// Get current navigator state
  NavigatorState? get currentState => navigatorKey.currentState;

  /// Navigate to named route
  Future<T?> navigateTo<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    _logger.logNavigation('Current', routeName);
    return currentState!.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Navigate and replace current route
  Future<T?> navigateAndReplace<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    _logger.logNavigation('Current (Replace)', routeName);
    return currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Navigate and clear all previous routes
  Future<T?> navigateAndClearAll<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    _logger.logNavigation('Current (Clear All)', routeName);
    return currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Go back to previous screen
  void goBack<T extends Object?>([T? result]) {
    if (canGoBack()) {
      _logger.logNavigation('Current', 'Back');
      currentState!.pop<T>(result);
    }
  }

  /// Check if can go back
  bool canGoBack() {
    return currentState?.canPop() ?? false;
  }

  /// Go back until specific route
  void goBackUntil(String routeName) {
    _logger.logNavigation('Current', 'Back Until $routeName');
    currentState!.popUntil(ModalRoute.withName(routeName));
  }

  /// Navigate using GoRouter context (if available)
  void goToRoute(String route, {Object? extra}) {
    if (currentContext != null) {
      _logger.logNavigation('Current', route);
      currentContext!.go(route, extra: extra);
    }
  }

  /// Push route using GoRouter context
  void pushRoute(String route, {Object? extra}) {
    if (currentContext != null) {
      _logger.logNavigation('Current', 'Push $route');
      currentContext!.push(route, extra: extra);
    }
  }

  /// Show dialog
  Future<T?> showAppDialog<T>({
    required Widget dialog,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    if (currentContext != null) {
      _logger.logUserAction('Show Dialog', {
        'barrierDismissible': barrierDismissible,
      });
      return showDialog<T>(
        context: currentContext!,
        builder: (_) => dialog,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
      );
    }
    return Future.value(null);
  }

  /// Show bottom sheet
  Future<T?> showAppBottomSheet<T>({
    required Widget content,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    if (currentContext != null) {
      _logger.logUserAction('Show Bottom Sheet', {
        'isScrollControlled': isScrollControlled,
        'isDismissible': isDismissible,
      });
      return showModalBottomSheet<T>(
        context: currentContext!,
        builder: (_) => content,
        isScrollControlled: isScrollControlled,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
      );
    }
    return Future.value(null);
  }

  /// Show snackbar
  void showSnackBar({
    required String message,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
  }) {
    if (currentContext != null) {
      _logger.logUserAction('Show SnackBar', {'message': message});
      ScaffoldMessenger.of(currentContext!).showSnackBar(
        SnackBar(
          content: Text(message),
          action: action,
          duration: duration,
          backgroundColor: backgroundColor,
        ),
      );
    }
  }

  /// Navigate to specific app routes
  void navigateToHome() => goToRoute(AppRoutes.home);
  void navigateToAuth() => goToRoute(AppRoutes.auth);
  void navigateToProfile() => goToRoute(AppRoutes.profile);
  void navigateToSettings() => goToRoute(AppRoutes.settings);
  void navigateToMovieDetail(String movieId) =>
      goToRoute('${AppRoutes.movieDetail}/$movieId');
}
