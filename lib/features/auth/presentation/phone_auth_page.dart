import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/config/constants/app_strings.dart';
import 'package:business_calendar/config/constants/app_routes.dart';
import 'package:business_calendar/shared/widgets/app_primary_button.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _phoneController = TextEditingController();
  bool _isAgreed = false;
  bool _isPhoneComplete = false;

  final _maskFormatter = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  void _onPhoneChanged(String value) {
    setState(() {
      _isPhoneComplete = _maskFormatter.isFill();
    });
  }

  void _onNext() {
    if (mounted) {
      final formattedNumber = _maskFormatter.getMaskedText();
      Navigator.pushNamed(
        context, 
        AppRoutes.otpVerification, 
        arguments: formattedNumber,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Иконка
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
              // Заголовок
              const Text(
                AppStrings.phoneAuthTitle,
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
                    const Text(
                      'Номер телефона',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                    TextField(
                      controller: _phoneController,
                      inputFormatters: [_maskFormatter],
                      keyboardType: TextInputType.phone,
                      onChanged: _onPhoneChanged,
                      decoration: const InputDecoration(
                        hintText: '+7 (___) ___-__-__',
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
                backgroundColor: (_isAgreed && _isPhoneComplete)
                    ? AppColors.buttonPrimary
                    : const Color(0x1E767680), // Fills-Tertiary style
                textColor: (_isAgreed && _isPhoneComplete)
                    ? Colors.white
                    : const Color(0x4C3C3C43), // Labels-Tertiary style
                onPressed: (_isAgreed && _isPhoneComplete) ? _onNext : () {},
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
    _phoneController.dispose();
    super.dispose();
  }
}
