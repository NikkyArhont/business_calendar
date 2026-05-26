import 'package:flutter/material.dart';
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/config/constants/app_routes.dart';
import 'package:business_calendar/shared/widgets/app_scaffold.dart';

class AssistantsPage extends StatelessWidget {
  const AssistantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Доступ',
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFF8E8E93)),
          onPressed: () {},
        ),
      ],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: double.infinity), // Чтобы колонна была на всю ширину
          // Кастомная иконка из ассетов
          Image.asset(
            'assets/emptyMem.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 32),
          // Текст описания
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Подключите помощника к управлению событиями',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 100), // Смещение чуть выше центра
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 8),
        child: SizedBox(
          width: 64,
          height: 64,
          child: FloatingActionButton(
            heroTag: 'assistants_fab',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addAssistant);
            },
            backgroundColor: const Color(0xFFFA4E02),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }
}
