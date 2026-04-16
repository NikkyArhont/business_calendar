import 'package:flutter/material.dart';
import '../config/constants/app_routes.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/calendar/presentation/calendar_page.dart';
import '../features/notes/presentation/note_list_page.dart';
import '../features/notes/presentation/note_detail_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/contacts/presentation/contact_list_page.dart';
import '../features/contacts/presentation/contact_detail_page.dart';
import '../features/assistants/presentation/assistants_page.dart';
import '../features/subscription/presentation/subscription_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case AppRoutes.auth:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case AppRoutes.calendar:
        return MaterialPageRoute(builder: (_) => const CalendarPage());
      case AppRoutes.notes:
        return MaterialPageRoute(builder: (_) => const NoteListPage());
      case AppRoutes.noteDetail:
        return MaterialPageRoute(builder: (_) => const NoteDetailPage());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case AppRoutes.contacts:
        return MaterialPageRoute(builder: (_) => const ContactListPage());
      case AppRoutes.contactDetail:
        return MaterialPageRoute(builder: (_) => const ContactDetailPage());
      case AppRoutes.assistants:
        return MaterialPageRoute(builder: (_) => const AssistantsPage());
      case AppRoutes.subscription:
        return MaterialPageRoute(builder: (_) => const SubscriptionPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Маршрут ${settings.name} не найден')),
          ),
        );
    }
  }
}
