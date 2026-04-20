import 'package:flutter/material.dart';
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/shared/widgets/app_alert_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: Column(
          children: [
            // Кастомный AppBar
            _buildAppBar(),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Карточка профиля
                    _buildUserInfoCard(),
                    
                    const SizedBox(height: 24),
                    // Список действий (Поделиться, Подписка)
                    _buildActionsList(),
                    
                    const SizedBox(height: 12),
                    // Кнопка Выйти
                    _buildActionCard(
                      title: 'Выйти из аккаунта',
                      onTap: () => _showConfirmDialog(
                        context,
                        title: 'Вы уверены, что хотите выйти из аккаунта?',
                        actionTitle: 'Выйти',
                        onAction: () {
                          // TODO: Логика выхода
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    // Кнопка Удалить (Красная)
                    _buildActionCard(
                      title: 'Удалить аккаунт',
                      isDestructive: true,
                      onTap: () => _showConfirmDialog(
                        context,
                        title: 'Вы уверены, что хотите удалить аккаунт?',
                        actionTitle: 'Удалить',
                        isDestructive: true,
                        onAction: () {
                          // TODO: Логика удаления
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String actionTitle,
    required VoidCallback onAction,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AppAlertDialog(
        title: title,
        actionTitle: actionTitle,
        onAction: onAction,
        isDestructive: isDestructive,
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: Alignment.centerLeft,
      child: const Text(
        'Профиль',
        style: TextStyle(
          color: Color(0xFF1C1B1F),
          fontSize: 22,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          height: 1.27,
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Аватар плейсхолдер
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.person, size: 60, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(height: 16),
          // Имя
          const Text(
            'Иван Иванов',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              letterSpacing: -0.31,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsList() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildActionItem(
            title: 'Поделиться календарем',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildActionItem(
            title: 'Подписка',
            subtitle: 'Активна',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isDestructive ? Colors.red : Colors.black,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            Icon(
              isDestructive ? Icons.delete_outline : Icons.chevron_right,
              color: isDestructive ? Colors.red : const Color(0xFF8E8E93),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        height: 56,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      height: 1.2,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFFFA4E02),
                        fontSize: 14,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF8E8E93),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
