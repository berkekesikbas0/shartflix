import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../core/theme/app_theme.dart';

class LimitedOfferBottomSheet extends StatelessWidget {
  const LimitedOfferBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF2D0A0A),
            const Color(0xFF1A0A0A),
            Colors.black.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Top Section - Limited Offer
          Container(
            padding: EdgeInsets.fromLTRB(6.w, 3.h, 6.w, 2.h),
            child: Column(
              children: [
                Text(
                  'Sınırlı Teklif',
                  style: TextStyle(
                    color: AppColors.shartflixWhite,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.5.h),
                Text(
                  'Jeton paketin\'ni seçerek bonus kazanın ve yeni bölümlerin kilidini açın!',
                  style: TextStyle(
                    color: AppColors.shartflixWhite,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Middle Section - Bonuses with Glass Effect
          Container(
            margin: EdgeInsets.symmetric(horizontal: 6.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Alacağınız Bonuslar',
                  style: TextStyle(
                    color: AppColors.shartflixWhite,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBonusItem(
                      icon: Icons.diamond,
                      label: 'Premium Hesap',
                      color: const Color(0xFFE91E63),
                    ),
                    _buildBonusItem(
                      icon: Icons.favorite,
                      label: 'Daha Fazla Eşleşme',
                      color: const Color(0xFFE91E63),
                    ),
                    _buildBonusItem(
                      icon: Icons.trending_up,
                      label: 'Öne Çıkarma',
                      color: const Color(0xFFE91E63),
                    ),
                    _buildBonusItem(
                      icon: Icons.favorite_border,
                      label: 'Daha Fazla Beğeni',
                      color: const Color(0xFFE91E63),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Bottom Section - Token Packages
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                children: [
                  Text(
                    'Kilidi açmak için bir jeton paketi seçin',
                    style: TextStyle(
                      color: AppColors.shartflixWhite,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2.5.h),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTokenPackage(
                            originalTokens: '200',
                            newTokens: '330',
                            price: '₺99,99',
                            bonus: '+10%',
                            isRecommended: false,
                            cardGradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF8B0000), Color(0xFFDC143C)],
                            ),
                            badgeGradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF8A2BE2), Color(0xFFE91E63)],
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: _buildTokenPackage(
                            originalTokens: '2.000',
                            newTokens: '3.375',
                            price: '₺799,99',
                            bonus: '+70%',
                            isRecommended: true,
                            cardGradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF8A2BE2), Color(0xFFE91E63)],
                            ),
                            badgeGradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF8A2BE2), Color(0xFFE91E63)],
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: _buildTokenPackage(
                            originalTokens: '1.000',
                            newTokens: '1.350',
                            price: '₺399,99',
                            bonus: '+35%',
                            isRecommended: false,
                            cardGradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF8B0000), Color(0xFFDC143C)],
                            ),
                            badgeGradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF8A2BE2), Color(0xFFE91E63)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Button
          Container(
            padding: EdgeInsets.fromLTRB(6.w, 0, 6.w, 3.h),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC143C),
                  foregroundColor: AppColors.shartflixWhite,
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.5),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Tüm Jetonları Gör',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBonusItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 14.w,
          height: 14.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 6.w),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: TextStyle(
            color: AppColors.shartflixWhite,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTokenPackage({
    required String originalTokens,
    required String newTokens,
    required String price,
    required String bonus,
    required bool isRecommended,
    required LinearGradient cardGradient,
    required LinearGradient badgeGradient,
  }) {
    return Container(
      height: 25.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Card
          Container(
            height: 25.h,
            decoration: BoxDecoration(
              gradient: cardGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 2.h), // Space for badge
                  // Original tokens (crossed out)
                  Text(
                    originalTokens,
                    style: TextStyle(
                      color: AppColors.shartflixWhite.withOpacity(0.7),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.lineThrough,
                      decorationThickness: 2,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  // New tokens
                  Text(
                    newTokens,
                    style: TextStyle(
                      color: AppColors.shartflixWhite,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 0.8.h),
                  Text(
                    'Jeton',
                    style: TextStyle(
                      color: AppColors.shartflixWhite,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 2.5.h),
                  // Divider line above price
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  SizedBox(height: 1.h),
                  // Price
                  Text(
                    price,
                    style: TextStyle(
                      color: AppColors.shartflixWhite,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 0.8.h),
                  Text(
                    'Başına haftalık',
                    style: TextStyle(
                      color: AppColors.shartflixWhite,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Badge positioned above the card
          Positioned(
            top: -1.2.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  gradient: badgeGradient,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.shartflixWhite,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  bonus,
                  style: TextStyle(
                    color: AppColors.shartflixWhite,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
