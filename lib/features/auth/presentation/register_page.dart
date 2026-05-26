import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/config/constants/app_strings.dart';
import 'package:business_calendar/config/constants/app_routes.dart';
import 'package:business_calendar/shared/widgets/app_primary_button.dart';
import 'package:business_calendar/core/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _authService = AuthService();
  bool _isNameFilled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        _isNameFilled = _nameController.text.trim().isNotEmpty;
      });
    });
    _nameFocusNode.addListener(() {
      setState(() {});
    });
  }

  Future<void> _onNext() async {
    if (_isLoading || !_isNameFilled) return;

    setState(() => _isLoading = true);

    try {
      await _authService.updateUserProfile(
        name: _nameController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.calendar,
          (route) => false,
        );
      }
    } catch (e) {
      if (kDebugMode) print('Error saving profile: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при сохранении профиля. Попробуйте еще раз.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Заголовок
              const Text(
                AppStrings.registerTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.logoGradientEnd,
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                AppStrings.registerSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              
              // Аватар
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/Preset.png',
                          width: 48,
                          height: 48,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE5E5EA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Поле имени
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.registerNameLabel,
                      style: TextStyle(
                        color: _nameFocusNode.hasFocus ? AppColors.logoGradientEnd : AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                    TextField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Кнопка Далее
              AppPrimaryButton(
                text: 'Далее',
                isLoading: _isLoading,
                backgroundColor: _isNameFilled 
                    ? AppColors.buttonPrimary 
                    : const Color(0x1E767680),
                textColor: _isNameFilled 
                    ? Colors.white 
                    : const Color(0x4C3C3C43),
                onPressed: _isNameFilled ? _onNext : () {},
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
