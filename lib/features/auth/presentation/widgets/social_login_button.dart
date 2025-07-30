import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class SocialLoginButton extends StatelessWidget {
  final SocialLoginType type;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.type,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(4.5.w),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.3.w),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4.5.w),
          child: Center(child: _buildIcon()),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (type) {
      case SocialLoginType.google:
        return Text(
          'G',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontFamily: AppTheme.fontFamily,
          ),
        );
      case SocialLoginType.apple:
        return Icon(Icons.apple, size: 18.sp, color: Colors.white);
      case SocialLoginType.facebook:
        return Text(
          'f',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: AppTheme.fontFamily,
          ),
        );
    }
  }
}

class SocialLoginRow extends StatelessWidget {
  final Function(SocialLoginType) onSocialLogin;

  const SocialLoginRow({super.key, required this.onSocialLogin});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialLoginButton(
          type: SocialLoginType.google,
          onPressed: () => onSocialLogin(SocialLoginType.google),
        ),
        SizedBox(width: 3.5.w),
        SocialLoginButton(
          type: SocialLoginType.apple,
          onPressed: () => onSocialLogin(SocialLoginType.apple),
        ),
        SizedBox(width: 3.5.w),
        SocialLoginButton(
          type: SocialLoginType.facebook,
          onPressed: () => onSocialLogin(SocialLoginType.facebook),
        ),
      ],
    );
  }
}
