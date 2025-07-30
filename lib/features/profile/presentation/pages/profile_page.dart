import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/injection/injection.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/favorite_movies_section.dart';
import '../widgets/limited_offer_bottom_sheet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shartflixBackground,
      appBar: ProfileAppBar(onLimitedOfferPressed: _onLimitedOfferPressed),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.shartflixRed),
            );
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hata: ${state.message}',
                    style: const TextStyle(
                      color: AppColors.shartflixWhite,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(const LoadProfileEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.shartflixRed,
                      foregroundColor: AppColors.shartflixWhite,
                    ),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileBloc>().add(const RefreshProfileEvent());
              },
              color: AppColors.shartflixRed,
              backgroundColor: AppColors.shartflixBlack,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Profile Info Section
                    ProfileInfoSection(
                      profile: state.profile,
                      onAddPhotoPressed: _onAddPhotoPressed,
                    ),
                    // Favorite Movies Section
                    FavoriteMoviesSection(
                      favoriteMovies: state.profile.favoriteMovies,
                    ),
                    const SizedBox(height: 100), // Extra space for bottom nav
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _onAddPhotoPressed() {
    final navigationService = getIt<NavigationService>();
    navigationService.navigateTo(AppRoutes.profilePhotoUpload);
  }

  void _onLimitedOfferPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LimitedOfferBottomSheet(),
    );
  }
}
