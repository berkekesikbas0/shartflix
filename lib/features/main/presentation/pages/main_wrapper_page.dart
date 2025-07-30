import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../core/injection/injection.dart';
// import '../../../../core/theme/app_theme.dart';
import '../../../movies/presentation/pages/home_page.dart';
import '../../../movies/presentation/bloc/movies_bloc.dart';
import '../../../movies/presentation/bloc/movies_event.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../bloc/navigation_bloc.dart';
import '../bloc/navigation_event.dart';
import '../bloc/navigation_state.dart';

/// Main wrapper page with bottom navigation
class MainWrapperPage extends StatefulWidget {
  const MainWrapperPage({super.key});

  @override
  State<MainWrapperPage> createState() => _MainWrapperPageState();
}

class _MainWrapperPageState extends State<MainWrapperPage> {
  @override
  void initState() {
    super.initState();
    // Trigger movies loading when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MoviesBloc>().add(LoadMoviesEvent());
      }
    });
  }

  Widget _buildBottomNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(25.sp),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationBloc(),
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          return Scaffold(
            body: IndexedStack(
              index: state.selectedIndex,
              children: [
                const HomePage(), // Anasayfa
                BlocProvider(
                  create: (context) {
                    final profileBloc = getIt<ProfileBloc>();
                    // Set Profile BLoC reference in Movies BLoC
                    final moviesBloc = getIt<MoviesBloc>();
                    moviesBloc.setProfileBloc(profileBloc);
                    print(
                      '🔗 Main Wrapper: Connected Movies BLoC to Profile BLoC',
                    );
                    return profileBloc;
                  },
                  child: const ProfilePage(), // Profil
                ),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(color: Colors.black),
              child: SafeArea(
                child: Container(
                  height: 10.h,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBottomNavItem(
                        context,
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        label: 'Anasayfa',
                        isSelected: state.selectedIndex == 0,
                        onTap:
                            () => context.read<NavigationBloc>().add(
                              NavigationTabChangedEvent(0),
                            ),
                      ),
                      _buildBottomNavItem(
                        context,
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: 'Profil',
                        isSelected: state.selectedIndex == 1,
                        onTap:
                            () => context.read<NavigationBloc>().add(
                              NavigationTabChangedEvent(1),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Placeholder page for profile
class ProfilePlaceholderPage extends StatelessWidget {
  const ProfilePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 64, color: Colors.grey[600]),
              const SizedBox(height: 16),
              const Text(
                'Profil Sayfası',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bu sayfa henüz geliştirilme aşamasında',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
