import 'package:flutter/material.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../config/constants/app_routes.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Вход',
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Email')),
            const TextField(decoration: InputDecoration(labelText: 'Пароль'), obscureText: true),
            const SizedBox(height: 20),
            AppPrimaryButton(
              text: 'Войти',
              onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.calendar),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
              child: const Text('Нет аккаунта? Регистрация'),
            ),
          ],
        ),
      ),
    );
  }
}
