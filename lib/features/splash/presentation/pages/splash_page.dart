import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/injection/injection.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    // Set the status bar to be transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _startSplashSequence();
  }

  void _startSplashSequence() async {
    final logger = getIt<LoggerService>();
    logger.info('🚀 Starting splash sequence');

    // Wait for splash duration
    await Future.delayed(AppConstants.splashDuration);

    // Check authentication status and navigate accordingly
    if (mounted) {
      final navigationService = getIt<NavigationService>();
      final authBloc = context.read<AuthBloc>();

      if (authBloc.isAuthenticated) {
        navigationService.navigateAndReplace(AppRoutes.auth);
      } else {
        navigationService.navigateAndReplace(AppRoutes.auth);
      }

      logger.info('✅ Splash sequence completed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.black),
        child: Image.asset(
          'assets/images/SinFlixSplash.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
