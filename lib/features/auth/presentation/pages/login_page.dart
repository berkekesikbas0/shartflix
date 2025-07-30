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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Temporary localization class until AppLocalizations is fixed
class _TempL10n {
  String get hello => 'Merhabalar';
  String get loginDescription =>
      'Tempus varius a vitae interdum id tortor elementum tristique eleifend at.';
  String get email => 'E-Posta';
  String get password => 'Şifre';
  String get emailRequired => 'E-posta gereklidir';
  String get enterValidEmail => 'Geçerli bir e-posta girin';
  String get passwordRequired => 'Şifre gereklidir';
  String get passwordMinLength => 'Şifre en az 6 karakter olmalıdır';
  String get forgotPassword => 'Şifremi unuttum';
  String get login => 'Giriş Yap';
  String get dontHaveAccount => 'Bir hesabın yok mu? ';
  String get register => 'Kayıt Ol!';
  String get loginSuccessful => 'Giriş başarılı';
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  void _onLoginPressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      LoginEvent(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _onSocialLogin(SocialLoginType type) {
    context.read<AuthBloc>().add(SocialLoginEvent(type));
  }

  void _onForgotPassword() {
    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Lütfen önce e-posta adresinizi giriniz');
      return;
    }

    context.read<AuthBloc>().add(
      ForgotPasswordEvent(_emailController.text.trim()),
    );
  }

  void _navigateToRegister() {
    final navigationService = getIt<NavigationService>();
    navigationService.navigateAndReplace(AppRoutes.register);
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
            _showErrorSnackBar(state.message);
          } else if (state is AuthAuthenticated) {
            _showSuccessSnackBar(l10n.loginSuccessful);
            final navigationService = getIt<NavigationService>();
            navigationService.navigateAndClearAll(AppRoutes.home);
          } else if (state is AuthSuccess) {
            _showSuccessSnackBar(state.message);
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
                    SizedBox(height: 25.h),

                    // Title
                    Text(
                      l10n.hello,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // Subtitle
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Text(
                        l10n.loginDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(1),
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),

                    SizedBox(height: 5.h),

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

                    SizedBox(height: 3.h),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: _onForgotPassword,
                        child: Text(
                          l10n.forgotPassword,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white,
                            fontFamily: AppTheme.fontFamily,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Login Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AuthPrimaryButton(
                          text: l10n.login,
                          onPressed: _onLoginPressed,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),

                    SizedBox(height: 4.h),

                    // Social Login
                    SocialLoginRow(onSocialLogin: _onSocialLogin),

                    SizedBox(height: 4.h),

                    // Register Link
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFFAAAAAA),
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w300,
                        ),
                        children: [
                          TextSpan(text: l10n.dontHaveAccount),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: _navigateToRegister,
                              child: Text(
                                l10n.register,
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
