import 'package:flutter/material.dart';
import 'package:business_calendar/config/constants/app_colors.dart';

class SidebarNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SidebarNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            width: 1,
            color: Color(0xFFEDEDED),
          ),
        ),
      ),
      child: Column(
        children: [
          // Логотип приложения
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias, // Чтобы скруглить углы самой картинки, если нужно
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 32),
          
          // Основной список элементов навигации
          Expanded(
            child: Column(
              children: [
                _buildNavItem(0, 'assets/menu/calendar.png', 'assets/menu/calendarOn.png', 'Календарь'),
                _buildNavItem(1, 'assets/menu/anal.png', 'assets/menu/analOn.png', 'Аналитика'),
                _buildNavItem(2, 'assets/menu/cont.png', 'assets/menu/contOn.png', 'Контакты'),
              ],
            ),
          ),
          
          // Профиль перемещен в самый низ
          _buildNavItem(3, 'assets/menu/profile.png', 'assets/menu/profileOn.png', 'Профиль'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath, String activeIconPath, String tooltip) {
    final bool isActive = currentIndex == index;

    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(bottom: 16),
          child: Center(
            child: Image.asset(
              isActive ? activeIconPath : iconPath,
              width: 24,
              height: 24,
            ),
          ),
        ),
      ),
    );
  }
}
