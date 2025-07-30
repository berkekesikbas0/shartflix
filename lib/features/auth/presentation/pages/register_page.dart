import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/injection/injection.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/social_login_button.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// Temporary localization class until AppLocalizations is fixed
class _TempL10n {
  String get welcome => 'Hoşgeldiniz';
  String get registerDescription =>
      'Tempus varius a vitae interdum id tortor elementum tristique eleifend at.';
  String get fullName => 'Ad Soyad';
  String get email => 'E-Posta';
  String get password => 'Şifre';
  String get confirmPassword => 'Şifre Tekrar';
  String get fullNameRequired => 'Ad soyad gereklidir';
  String get fullNameMinLength => 'Ad soyad en az 2 karakter olmalıdır';
  String get emailRequired => 'E-posta gereklidir';
  String get enterValidEmail => 'Geçerli bir e-posta girin';
  String get passwordRequired => 'Şifre gereklidir';
  String get passwordMinLength => 'Şifre en az 6 karakter olmalıdır';
  String get confirmPasswordRequired => 'Şifre tekrarı gereklidir';
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';
  String get termsPrefix => 'Kullanıcı sözleşmesini ';
  String get termsLink => 'okudum ve kabul ediyorum';
  String get termsSuffix => '. Bu sözleşmeyi okuyarak devam ediniz lütfen.';
  String get signUp => 'Şimdi Kaydol';
  String get alreadyHaveAccount => 'Zaten bir hesabın var mı? ';
  String get login => 'Giriş Yap!';
  String get registerSuccessful => 'Kayıt başarılı';
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
      ),
    );
  }

  void _handleValidationErrors(Map<String, List<String>> validationErrors) {
    // Show field-specific validation errors
    for (final entry in validationErrors.entries) {
      final field = entry.key;
      final errors = entry.value;

      if (errors.isNotEmpty) {
        final errorMessage = errors.first; // Show first error for each field

        switch (field.toLowerCase()) {
          case 'email':
            _showFieldErrorSnackBar('Email', errorMessage);
            break;
          case 'password':
            _showFieldErrorSnackBar('Şifre', errorMessage);
            break;
          case 'name':
            _showFieldErrorSnackBar('İsim', errorMessage);
            break;
          default:
            _showFieldErrorSnackBar(field, errorMessage);
        }
      }
    }
  }

  void _showFieldErrorSnackBar(String field, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$field: $message'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _onRegisterPressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      RegisterEvent(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
    );
  }

  void _onSocialLogin(SocialLoginType type) {
    context.read<AuthBloc>().add(SocialLoginEvent(type));
  }

  void _navigateToLogin() {
    final navigationService = getIt<NavigationService>();
    navigationService.navigateAndReplace(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    // Temporary strings until localization is fixed
    final l10n = _TempL10n();

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            // Show main error message
            _showErrorSnackBar(state.message);

            // Handle validation errors for specific fields
            if (state.validationErrors != null) {
              _handleValidationErrors(state.validationErrors!);
            }
          } else if (state is AuthAuthenticated) {
            _showSuccessSnackBar(l10n.registerSuccessful);
            final navigationService = getIt<NavigationService>();
            navigationService.navigateTo(AppRoutes.home);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 5.h),

                    // Title
                    Text(
                      l10n.welcome,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),

                    SizedBox(height: 1.5.h),

                    // Subtitle
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Text(
                        l10n.registerDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFFAAAAAA),
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w300,
                          height: 1.4,
                        ),
                      ),
                    ),

                    SizedBox(height: 5.h),

                    // Name Field
                    AuthTextField(
                      hintText: l10n.fullName,
                      prefixIcon: Icons.person_outline,
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.fullNameRequired;
                        }
                        if (value.trim().length < 2) {
                          return l10n.fullNameMinLength;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 2.h),

                    // Email Field
                    AuthTextField(
                      hintText: l10n.email,
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.emailRequired;
                        }
                        if (!value.contains('@')) {
                          return l10n.enterValidEmail;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 2.h),

                    // Password Field
                    AuthTextField(
                      hintText: l10n.password,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.passwordRequired;
                        }
                        if (value.length < 6) {
                          return l10n.passwordMinLength;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 2.h),

                    // Confirm Password Field
                    AuthTextField(
                      hintText: l10n.confirmPassword,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.confirmPasswordRequired;
                        }
                        if (value != _passwordController.text) {
                          return l10n.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Terms text
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.5.w),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFFAAAAAA),
                            fontFamily: AppTheme.fontFamily,
                            fontWeight: FontWeight.w300,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(text: l10n.termsPrefix),
                            TextSpan(
                              text: l10n.termsLink,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: l10n.termsSuffix),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Register Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AuthPrimaryButton(
                          text: l10n.signUp,
                          onPressed: _onRegisterPressed,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),

                    SizedBox(height: 4.h),

                    // Social Login
                    SocialLoginRow(onSocialLogin: _onSocialLogin),

                    SizedBox(height: 4.h),

                    // Login Link
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFFAAAAAA),
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w300,
                        ),
                        children: [
                          TextSpan(text: l10n.alreadyHaveAccount),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: _navigateToLogin,
                              child: Text(
                                l10n.login,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppTheme.fontFamily,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 5.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
