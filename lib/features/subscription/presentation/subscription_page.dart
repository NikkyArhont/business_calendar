import 'package:flutter/material.dart';
import '../../../shared/widgets/app_scaffold.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Подписка',
      body: Center(child: Text('Выбор тарифного плана')),
    );
  }
}
