import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/config/constants/app_strings.dart';
import 'package:business_calendar/config/constants/app_routes.dart';
import 'package:business_calendar/shared/widgets/app_primary_button.dart';
import 'package:business_calendar/shared/widgets/responsive_auth_layout.dart';
import 'package:business_calendar/shared/widgets/social_auth_button.dart';
import 'package:business_calendar/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _authService = AuthService();
  bool _isAgreed = false;
  bool _isPhoneComplete = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() {});
    });
  }

  final _maskFormatter = MaskTextInputFormatter(
    mask: '(###) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  void _onPhoneChanged(String value) {
    setState(() {
      _isPhoneComplete = _maskFormatter.isFill();
    });
  }

  Future<void> _onNext() async {
    if (_isLoading) return;

    final phone = _maskFormatter.getUnmaskedText();
    // Firebase требует формат +7...
    final fullPhone = '+7$phone';

    setState(() => _isLoading = true);

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: fullPhone,
        onCodeSent: (verificationId) {
          setState(() => _isLoading = false);
          Navigator.pushNamed(
            context,
            AppRoutes.otpVerification,
            arguments: {
              'phoneNumber': _maskFormatter.getMaskedText(),
              'verificationId': verificationId,
            },
          );
        },
        onError: (e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Ошибка при отправке SMS')),
          );
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Произошла непредвиденная ошибка')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.splashBackground,
        body: ResponsiveAuthLayout(
          showBackButton: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Иконка (скрываем на широких экранах, так как есть большое лого слева)
                  if (MediaQuery.of(context).size.width <= 800) ...[
                    Image.asset(
                      'assets/call.png',
                      width: 80,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.phone_in_talk,
                        size: 80,
                        color: AppColors.logoGradientEnd,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Заголовок
                  const Text(
                    AppStrings.phoneAuthTitle, // "Войти"
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.logoGradientEnd, // На макете черный "Войти"? Оставим как было в AppStrings, или сделаем черным?
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (MediaQuery.of(context).size.width <= 800) ...[
                    const Text(
                      AppStrings.phoneAuthSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ] else ...[
                    const SizedBox(height: 32),
                  ],
                  
                  // Поле ввода
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
                          'Номер телефона',
                          style: TextStyle(
                            color: _phoneFocusNode.hasFocus ? AppColors.logoGradientEnd : AppColors.textSecondary,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                        TextField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          inputFormatters: [_maskFormatter],
                          keyboardType: TextInputType.phone,
                          onChanged: _onPhoneChanged,
                          decoration: const InputDecoration(
                            prefixText: '+7 ',
                            prefixStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: '(___) ___-__-__',
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
                  
                  const SizedBox(height: 24),
                  
                  // Чекбокс согласия
                  GestureDetector(
                    onTap: () => setState(() => _isAgreed = !_isAgreed),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _isAgreed,
                          activeColor: AppColors.logoGradientEnd,
                          onChanged: (value) => setState(() => _isAgreed = value ?? false),
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: AppStrings.phoneAuthTermsPre,
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                                TextSpan(
                                  text: AppStrings.phoneAuthTermsLink1,
                                  style: const TextStyle(
                                    color: AppColors.logoGradientEnd,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(
                                  text: AppStrings.phoneAuthTermsAnd,
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                                TextSpan(
                                  text: AppStrings.phoneAuthTermsLink2,
                                  style: const TextStyle(
                                    color: AppColors.logoGradientEnd,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                            style: const TextStyle(fontFamily: 'Inter', height: 1.33),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Кнопка Далее
                  AppPrimaryButton(
                    text: 'Далее',
                    isLoading: _isLoading,
                    backgroundColor: (_isAgreed && _isPhoneComplete)
                        ? AppColors.buttonPrimary
                        : const Color(0x1E767680), // Fills-Tertiary style
                    textColor: (_isAgreed && _isPhoneComplete)
                        ? Colors.white
                        : const Color(0x4C3C3C43), // Labels-Tertiary style
                    onPressed: (_isAgreed && _isPhoneComplete) ? _onNext : () {},
                  ),
                  const SizedBox(height: 24),

                  // Разделитель "Или"
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFC6C6C8))),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Или',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFC6C6C8))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Продолжить с Google
                  SocialAuthButton(
                    text: 'Продолжить с Google',
                    icon: Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      child: const Text(
                        'G',
                        style: TextStyle(
                          color: Color(0xFFEA4335), // Google Red
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        setState(() => _isLoading = true);
                        final credential = await _authService.signInWithGoogle();
                        setState(() => _isLoading = false);
                        if (credential != null && mounted) {
                          final isComplete = await _authService.isProfileComplete();
                          if (isComplete) {
                            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.calendar, (route) => false);
                          } else {
                            Navigator.pushNamed(context, AppRoutes.register);
                          }
                        }
                      } catch (e) {
                        setState(() => _isLoading = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ошибка входа через Google')),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Продолжить с Apple
                  SocialAuthButton(
                    text: 'Продолжить с Apple',
                    icon: const Icon(Icons.apple, size: 24, color: Colors.black),
                    onPressed: () {
                      // Логика для Apple
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Вход через Apple в разработке')),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
