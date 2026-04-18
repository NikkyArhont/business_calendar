import 'package:flutter/material.dart';
import 'package:business_calendar/config/constants/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x0C343434),
            blurRadius: 20,
            offset: Offset(0, -2),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTabItem(
                  index: 0,
                  icon: Icons.calendar_month,
                  activeIcon: Icons.calendar_month,
                  label: 'Календарь',
                ),
                _buildTabItem(
                  index: 1,
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart,
                  label: 'Аналитика',
                ),
                _buildTabItem(
                  index: 2,
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Контакты',
                ),
                _buildTabItem(
                  index: 3,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Профиль',
                ),
              ],
            ),
          ),
          // Нижний индикатор системы (Home Indicator)
          Container(
            width: double.infinity,
            height: 21,
            alignment: Alignment.center,
            child: Container(
              width: 139,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isActive = currentIndex == index;
    final Color color = isActive ? const Color(0xFFFA4E02) : const Color(0xFF8E8E93);

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 32,
              alignment: Alignment.center,
              child: Icon(
                isActive ? activeIcon : icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.45,
                letterSpacing: -0.40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
