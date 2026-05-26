import 'package:flutter/material.dart';
import '../config/constants/app_routes.dart';
import '../features/splash/presentation/splash_page.dart';
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
import '../features/assistants/presentation/add_assistant_page.dart';
import '../features/assistants/presentation/qr_share_page.dart';
import '../features/analytics/presentation/tag_selection_page.dart';
import '../features/analytics/presentation/edit_tags_page.dart';
import '../features/analytics/presentation/analytics_results_page.dart';
import '../features/subscription/presentation/subscription_page.dart';
import '../features/auth/presentation/phone_auth_page.dart';
import '../features/auth/presentation/otp_verification_page.dart';
import 'package:business_calendar/features/home/presentation/main_navigation_screen.dart';
import 'package:business_calendar/features/contacts/presentation/add_contact_page.dart';
import 'package:business_calendar/features/calendar/presentation/add_event_page.dart';
import 'package:business_calendar/features/contacts/presentation/contact_selection_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case AppRoutes.auth:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.phoneAuth:
        return MaterialPageRoute(builder: (_) => const PhoneAuthPage());
      case AppRoutes.otpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        final phoneNumber = args?['phoneNumber'] as String? ?? '';
        final verificationId = args?['verificationId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => OtpVerificationPage(
            phoneNumber: phoneNumber,
            verificationId: verificationId,
          ),
        );
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case AppRoutes.main:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      case AppRoutes.calendar:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      case AppRoutes.notes:
        return MaterialPageRoute(builder: (_) => const NoteListPage());
      case AppRoutes.noteDetail:
        return MaterialPageRoute(builder: (_) => const NoteDetailPage());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case AppRoutes.contacts:
        return MaterialPageRoute(builder: (_) => const ContactListPage());
      case AppRoutes.contactDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final contactId = args?['contactId'] as String? ?? '';
        return MaterialPageRoute(builder: (_) => ContactDetailPage(contactId: contactId));
      case AppRoutes.assistants:
        return MaterialPageRoute(builder: (_) => const AssistantsPage());
      case AppRoutes.addAssistant:
        return MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const AddAssistantPage(),
        );
      case AppRoutes.qrShare:
        return MaterialPageRoute(builder: (_) => const QrSharePage());
      case AppRoutes.tagSelection:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TagSelectionPage(
            title: args['title'] as String,
            initialSelectedTags: args['initialSelectedTags'] as List<String>,
            availableTags: args['availableTags'] as List<String>,
          ),
        );
      case AppRoutes.editTags:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EditTagsPage(
            title: args['title'] as String,
            availableTags: args['availableTags'] as List<String>,
          ),
        );
      case AppRoutes.analyticsResults:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AnalyticsResultsPage(
            filters: args['filters'] as Map<String, dynamic>,
          ),
        );
      case AppRoutes.subscription:
        return MaterialPageRoute(builder: (_) => const SubscriptionPage());
      case AppRoutes.addContact:
        return MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const AddContactPage(),
        );
      case AppRoutes.addEvent:
        return MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const AddEventPage(),
        );
      case AppRoutes.selectContacts:
        final args = settings.arguments as Map<String, dynamic>?;
        final initialSelectedIds = args?['initialSelectedIds'] as List<String>? ?? [];
        return MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => ContactSelectionPage(initialSelectedIds: initialSelectedIds),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Маршрут ${settings.name} не найден')),
          ),
        );
    }
  }
}
