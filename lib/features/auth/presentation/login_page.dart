import 'package:flutter/material.dart';
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/config/constants/app_strings.dart';
import 'package:business_calendar/config/constants/app_routes.dart';
import 'package:business_calendar/shared/widgets/app_primary_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: Stack(
        children: [
          // Верхняя часть с градиентом
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
              child: Column(
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
                  AppPrimaryButton(
                    text: AppStrings.loginWithPhone,
                    prefixIcon: const Icon(Icons.phone_android, color: Colors.white),
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
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, AppRoutes.calendar, (route) => false);
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  AppPrimaryButton(
                    text: AppStrings.loginWithApple,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    prefixIcon: const Icon(Icons.apple, size: 24),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
