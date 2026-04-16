import 'package:flutter/material.dart';
import 'app/app.dart';

void main() {
  // Тут в будущем будет инициализация Firebase, логирования и т.д.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BusinessCalendarApp());
}
