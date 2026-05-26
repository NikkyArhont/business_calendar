import 'package:flutter/material.dart';
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/config/constants/app_strings.dart';
import 'package:business_calendar/config/constants/app_routes.dart';
import 'package:business_calendar/shared/widgets/app_primary_button.dart';
import 'package:business_calendar/shared/widgets/responsive_auth_layout.dart';
import 'package:business_calendar/core/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        final isComplete = await _authService.isProfileComplete();
        if (mounted) {
          if (isComplete) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
          } else {
            Navigator.pushNamed(context, AppRoutes.register);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка входа: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;

    final formContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.loginWelcome,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.splashTitle,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          AppStrings.loginSelectMethod,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 48),
        
        // Кнопки авторизации
        _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.logoGradientEnd))
          : Column(
              children: [
                AppPrimaryButton(
                  text: AppStrings.loginWithPhone,
                  prefixIcon: const Icon(Icons.phone, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.phoneAuth);
                  },
                ),
                const SizedBox(height: 12),
                
                AppPrimaryButton(
                  text: AppStrings.loginWithGoogle,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  prefixIcon: const Icon(Icons.g_mobiledata, size: 30),
                  onPressed: _handleGoogleSignIn,
                ),
                const SizedBox(height: 12),
                
                Opacity(
                  opacity: 0.6,
                  child: AppPrimaryButton(
                    text: AppStrings.loginWithApple,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    prefixIcon: const Icon(Icons.apple, size: 24),
                    onPressed: () {}, // Не активно
                  ),
                ),
              ],
            ),
      ],
    );
    
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: ResponsiveAuthLayout(
        child: isWeb
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: formContent,
            )
          : Stack(
              children: [
                // Верхняя часть с градиентом (только для моб)
                Container(
                  width: double.infinity,
                  height: size.height * 0.45,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        AppColors.logoGradientStart,
                        AppColors.logoGradientEnd,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                
                // Белая панель с кнопками
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: size.height * 0.6,
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                    decoration: const BoxDecoration(
                      color: AppColors.splashBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: formContent,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
