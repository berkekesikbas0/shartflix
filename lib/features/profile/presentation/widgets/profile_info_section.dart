import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileInfoSection extends StatelessWidget {
  final UserProfileEntity profile;
  final VoidCallback? onAddPhotoPressed;

  const ProfileInfoSection({
    super.key,
    required this.profile,
    this.onAddPhotoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.shartflixBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile Photo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.shartflixDarkGray,
                ),
                child:
                    profile.profilePhotoUrl != null &&
                            profile.profilePhotoUrl!.isNotEmpty
                        ? ClipOval(
                          child: Image.network(
                            profile.profilePhotoUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: AppColors.shartflixDarkGray,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.shartflixRed,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('⚠️ Error loading profile image: $error');
                              return const Icon(
                                Icons.person,
                                color: AppColors.shartflixWhite,
                                size: 30,
                              );
                            },
                          ),
                        )
                        : const Icon(
                          Icons.person,
                          color: AppColors.shartflixWhite,
                          size: 30,
                        ),
              ),
              const SizedBox(width: 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        color: AppColors.shartflixWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${profile.id.length > 8 ? '${profile.id.substring(0, 8)}...' : profile.id}',
                      style: const TextStyle(
                        color: AppColors.shartflixWhite,
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              // Add Photo Button
              ElevatedButton(
                onPressed: onAddPhotoPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.shartflixRed,
                  foregroundColor: AppColors.shartflixWhite,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Fotoğraf Ekle',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
