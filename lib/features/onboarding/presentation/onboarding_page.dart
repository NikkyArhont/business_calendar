import 'package:flutter/material.dart';
import '../../../config/constants/app_routes.dart';
import '../../../config/constants/app_colors.dart';
import '../../../config/constants/app_strings.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/app_primary_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _screens = [
    OnboardingData(
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      image: 'assets/onboard1.png',
    ),
    OnboardingData(
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      image: 'assets/onboard2.png',
    ),
    OnboardingData(
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      image: 'assets/onboard3.png',
    ),
  ];

  void _onNext() async {
    if (_currentPage < _screens.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await StorageService.setFirstTime(false);
      if (mounted) {
        final authService = AuthService();
        final user = authService.currentUser;
        if (user != null) {
          final isProfileComplete = await authService.isProfileComplete();
          if (mounted) {
            if (isProfileComplete) {
              Navigator.pushReplacementNamed(context, AppRoutes.calendar);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.register);
            }
          }
        } else {
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.auth);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.splashBackground,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                controller: _pageController,
                itemCount: _screens.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return OnboardingSlide(data: _screens[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  AppPrimaryButton(
                    text: 'Далее',
                    onPressed: _onNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
  });
}

class OnboardingSlide extends StatelessWidget {
  final OnboardingData data;

  const OnboardingSlide({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Изображение растягивается по ширине
        Expanded(
          flex: 6,
          child: SizedBox(
            width: double.infinity,
            child: Image.asset(
              data.image,
              fit: BoxFit.fitWidth,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 100,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Контент (заголовок и описание)
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.splashTitle,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
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
}
