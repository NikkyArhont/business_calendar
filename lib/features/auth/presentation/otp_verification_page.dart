import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/config/constants/app_strings.dart';
import 'package:business_calendar/config/constants/app_routes.dart';
import 'package:business_calendar/shared/widgets/app_primary_button.dart';
import 'package:business_calendar/core/services/auth_service.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _authService = AuthService();
  
  int _timerSeconds = 60;
  Timer? _timer;
  bool _canResend = false;
  bool _isComplete = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Автофокус на первую ячейку
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        setState(() {
          _canResend = true;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    
    _checkIsComplete();
  }

  void _onBackspace(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent && 
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty && 
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _checkIsComplete() {
    final code = _controllers.map((c) => c.text).join();
    setState(() {
      _isComplete = code.length == 6;
    });
  }

  Future<void> _onNext() async {
    if (_isLoading) return;

    final code = _controllers.map((c) => c.text).join();
    setState(() => _isLoading = true);

    try {
      final credential = await _authService.signInWithCode(
        verificationId: widget.verificationId,
        smsCode: code,
      );

      if (credential != null && mounted) {
        final isComplete = await _authService.isProfileComplete();
        setState(() => _isLoading = false);
        
        if (isComplete) {
          Navigator.pushNamedAndRemoveUntil(
            context, 
            AppRoutes.calendar, 
            (route) => false,
          );
        } else {
          Navigator.pushNamed(context, AppRoutes.register);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Неверный код. Попробуйте еще раз.')),
      );
    }
  }

  String _formatTimer() {
    final minutes = (_timerSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_timerSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
              // Иконка
              Image.asset(
                'assets/sms-tracking.png',
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.sms_outlined,
                  size: 80,
                  color: AppColors.logoGradientEnd,
                ),
              ),
              const SizedBox(height: 24),
              // Заголовок
              const Text(
                AppStrings.otpTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.logoGradientEnd,
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppStrings.otpSubtitle} ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              
              // Поля ввода кода
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpBox(index)),
              ),
              
              const Spacer(),
              
              // Повторная отправка
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _canResend ? _startTimer : null,
                    child: Text(
                      AppStrings.otpResend,
                      style: TextStyle(
                        color: _canResend ? AppColors.logoGradientEnd : AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!_canResend)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatTimer(),
                        style: const TextStyle(
                          color: AppColors.logoGradientEnd,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Кнопка Далее
              AppPrimaryButton(
                text: 'Далее',
                isLoading: _isLoading,
                backgroundColor: _isComplete 
                    ? AppColors.buttonPrimary 
                    : const Color(0x1E767680),
                textColor: _isComplete 
                    ? Colors.white 
                    : const Color(0x4C3C3C43),
                onPressed: _isComplete ? _onNext : () {},
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: RawKeyboardListener(
        focusNode: FocusNode(), // Dummy focus node for listener
        onKey: (event) => _onBackspace(index, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          onChanged: (value) => _onOtpChanged(index, value),
          decoration: InputDecoration(
            counterText: "",
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _controllers[index].text.isNotEmpty ? AppColors.logoGradientEnd : Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.logoGradientEnd, width: 2),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}
