import 'package:flutter/material.dart';
import '../../../shared/widgets/app_scaffold.dart';

class NoteDetailPage extends StatelessWidget {
  const NoteDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Детали заметки',
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(decoration: InputDecoration(hintText: 'Заголовок')),
            SizedBox(height: 16),
            Expanded(child: TextField(maxLines: null, decoration: InputDecoration(hintText: 'Текст заметки'))),
          ],
        ),
      ),
    );
  }
}
