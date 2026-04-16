import 'package:flutter/material.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_empty_state.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Календарь',
      body: AppEmptyState(message: 'Событий пока нет'),
    );
  }
}
