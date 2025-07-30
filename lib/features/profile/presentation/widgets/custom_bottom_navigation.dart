import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.shartflixBlack,
        border: Border(
          top: BorderSide(color: AppColors.shartflixDarkGray, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Home Button
          Expanded(
            child: _buildNavButton(
              icon: Icons.home,
              label: 'Anasayfa',
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          // Profile Button
          Expanded(
            child: _buildNavButton(
              icon: Icons.person,
              label: 'Profil',
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.shartflixDarkGray : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? AppColors.shartflixRed
                      : AppColors.shartflixWhite,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? AppColors.shartflixRed
                        : AppColors.shartflixWhite,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
