import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/shared/widgets/app_primary_button.dart';

class QrSharePage extends StatelessWidget {
  const QrSharePage({super.key});

  static const String _inviteLink = 'http://LinkExample.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              if (kIsWeb) {
                // Закрываем оба модальных окна (QR и AddAssistant)
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              } else {
                // Возвращаемся в начало (к экрану профиля) без возможности уйти назад
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: const Text(
              'Готово',
              style: TextStyle(
                color: Color(0xFFFA4E02),
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Контейнер для QR-кода
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 180,
                  color: Color(0xFFFA4E02),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Передача прав',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF070C13),
                fontSize: 24,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Отсканируйте QR-код, чтобы поделиться доступом к календарю',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF95969C),
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.33,
              ),
            ),
            const SizedBox(height: 32),
            // Поле с ссылкой
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      _inviteLink,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        height: 1.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: Color(0xFFFA4E02), size: 24),
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: _inviteLink));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ссылка скопирована')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            AppPrimaryButton(
              text: 'Отправить',
              onPressed: () {
                Share.share('Присоединяйтесь к моему календарю: $_inviteLink');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
