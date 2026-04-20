import 'package:flutter/material.dart';
import 'package:business_calendar/features/calendar/presentation/calendar_page.dart';
import 'package:business_calendar/features/contacts/presentation/contact_list_page.dart';
import 'package:business_calendar/features/analytics/presentation/analytics_page.dart';
import 'package:business_calendar/features/profile/presentation/profile_page.dart';
import 'package:business_calendar/shared/widgets/app_bottom_nav.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CalendarPage(),
    const AnalyticsPage(),
    const ContactListPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
