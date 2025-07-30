import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Core imports
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/services/navigation_service.dart';
import 'core/services/firebase_service.dart';
import 'core/routing/app_router.dart';
import 'core/presentation/bloc/localization/localization_bloc.dart';
import 'core/presentation/bloc/theme/theme_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/movies/presentation/bloc/movies_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'core/injection/injection.dart';

// Features - handled by AppRouter

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await configureDependencies();

  // Initialize Firebase (optional for development)
  try {
    final firebaseService = getIt<FirebaseService>();
    await firebaseService.initialize();
  } catch (e) {
    // Firebase initialization failed - continue without Firebase
    // This is expected when GoogleService-Info.plist is missing on iOS
    print('Firebase initialization failed: $e');
    print('Continuing without Firebase services...');
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Run the app
  runApp(const ShartflixApp());
}

class ShartflixApp extends StatelessWidget {
  const ShartflixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BLoCs
        BlocProvider<LocalizationBloc>(
          create: (_) => getIt<LocalizationBloc>(),
        ),
        BlocProvider<ThemeBloc>(create: (_) => getIt<ThemeBloc>()),
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
        BlocProvider<MoviesBloc>(create: (_) => getIt<MoviesBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => getIt<ProfileBloc>()),
      ],
      child: BlocBuilder<LocalizationBloc, LocalizationState>(
        builder: (context, localizationState) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              // Get current values from BLoC states
              final locale =
                  localizationState is LocalizationLoaded
                      ? localizationState.currentLanguage.locale
                      : const Locale('tr', 'TR');

              final supportedLocales =
                  localizationState is LocalizationLoaded
                      ? localizationState.availableLanguages
                          .map((l) => l.locale)
                          .toList()
                      : [const Locale('tr', 'TR'), const Locale('en', 'US')];

              final themeMode =
                  themeState is ThemeLoaded
                      ? context.read<ThemeBloc>().effectiveThemeMode
                      : ThemeMode.system;

              return ResponsiveSizer(
                builder: (context, orientation, screenType) {
                  return MaterialApp(
                    // App Configuration
                    title: AppConstants.appName,
                    debugShowCheckedModeBanner: false,

                    // Navigation
                    navigatorKey: NavigationService.navigatorKey,
                    onGenerateRoute: getIt<AppRouter>().generateRoute,
                    initialRoute: AppRoutes.splash,

                    // Localization
                    locale: locale,
                    supportedLocales: supportedLocales,
                    localizationsDelegates: [
                      // AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],

                    // Theme
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeMode,

                    // Builder for additional configurations
                    builder: (context, child) {
                      return MediaQuery(
                        // Ensure text scaling is controlled
                        data: MediaQuery.of(context).copyWith(
                          textScaler: MediaQuery.of(context).textScaler.clamp(
                            minScaleFactor: 0.8,
                            maxScaleFactor: 1.2,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
