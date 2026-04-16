import 'package:flutter/material.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../config/constants/app_routes.dart';

class NoteListPage extends StatelessWidget {
  const NoteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Заметки',
      body: const AppEmptyState(message: 'Заметок пока нет'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.noteDetail),
        child: const Icon(Icons.add),
      ),
    );
  }
}
