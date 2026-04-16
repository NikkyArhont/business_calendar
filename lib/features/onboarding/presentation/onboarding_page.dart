import 'package:flutter/material.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../config/constants/app_routes.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Бизнес Календарь',
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month, size: 100, color: Colors.blue),
            const SizedBox(height: 40),
            const Text(
              'Управляйте вашим временем эффективно',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            AppPrimaryButton(
              text: 'Начать работу',
              onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.auth),
            ),
          ],
        ),
      ),
    );
  }
}
