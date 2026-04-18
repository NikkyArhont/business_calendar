import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'router.dart';
import 'theme.dart';
import '../config/constants/app_routes.dart';

class BusinessCalendarApp extends StatelessWidget {
  const BusinessCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Calendar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('en', 'US'),
      ],
    );
  }
}
