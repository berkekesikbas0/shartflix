import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/injection/injection.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onLimitedOfferPressed;

  const ProfileAppBar({
    super.key,
    this.onBackPressed,
    this.onLimitedOfferPressed,
  });

  void _handleBackPress(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.shartflixDarkGray,
            title: const Text(
              'Çıkış Yapmak',
              style: TextStyle(
                color: AppColors.shartflixWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Çıkış yapmak istediğinize emin misiniz?',
              style: TextStyle(color: AppColors.shartflixWhite),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Hayır',
                  style: TextStyle(color: AppColors.shartflixWhite),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<AuthBloc>().add(const LogoutEvent());
                  final navigationService = getIt<NavigationService>();
                  navigationService.navigateAndClearAll(AppRoutes.auth);
                },
                child: Text(
                  'Evet',
                  style: TextStyle(color: AppColors.shartflixRed),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.shartflixBackground,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.shartflixDarkGray,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.shartflixWhite,
            size: 18,
          ),
          onPressed: onBackPressed ?? () => _handleBackPress(context),
        ),
      ),
      title: const Text(
        'Profil Detayı',
        style: TextStyle(
          color: AppColors.shartflixWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.shartflixRed,
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: onLimitedOfferPressed,
              borderRadius: BorderRadius.circular(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.diamond,
                    size: 14,
                    color: AppColors.shartflixWhite,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Sınırlı Teklif',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.shartflixWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
