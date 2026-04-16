import 'package:flutter/material.dart';
import '../../../shared/widgets/app_scaffold.dart';

class AssistantsPage extends StatelessWidget {
  const AssistantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Ассистенты',
      body: Center(child: Text('Управление доступом ассистентов')),
    );
  }
}
