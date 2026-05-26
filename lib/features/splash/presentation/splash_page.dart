import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../config/constants/app_routes.dart';
import '../../../config/constants/app_colors.dart';
import '../../../config/constants/app_strings.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Задержка 2 секунды
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      final isFirstTime = await StorageService.isFirstTime();
      if (isFirstTime && !kIsWeb) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      } else {
        // Проверяем авторизацию
        final user = _authService.currentUser;
        if (user != null) {
          final isProfileComplete = await _authService.isProfileComplete();
          if (isProfileComplete) {
            Navigator.pushReplacementNamed(context, AppRoutes.calendar);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.register);
          }
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.auth);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Контейнер логотипа
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.logoGradientStart,
                    AppColors.logoGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.calendar_month,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Заголовок
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppStrings.splashTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.splashTitle,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  height: 1.21,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
