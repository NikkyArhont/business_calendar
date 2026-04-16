import 'package:flutter/material.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../config/constants/app_routes.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Регистрация',
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Имя')),
            const TextField(decoration: InputDecoration(labelText: 'Email')),
            const TextField(decoration: InputDecoration(labelText: 'Пароль'), obscureText: true),
            const SizedBox(height: 20),
            AppPrimaryButton(
              text: 'Создать аккаунт',
              onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.calendar),
            ),
          ],
        ),
      ),
    );
  }
}
