import 'package:flutter/material.dart';
import '../../../shared/widgets/app_scaffold.dart';

class ContactDetailPage extends StatelessWidget {
  const ContactDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Детали контакта',
      body: Center(child: Text('Информация о контакте')),
    );
  }
}
