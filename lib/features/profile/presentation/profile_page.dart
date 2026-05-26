import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/config/constants/app_routes.dart';
import 'package:business_calendar/shared/widgets/app_alert_dialog.dart';
import 'package:business_calendar/core/services/auth_service.dart';
import 'package:business_calendar/core/services/firestore_service.dart';
import 'package:business_calendar/core/models/assistant_access.dart';
import 'package:business_calendar/features/assistants/presentation/add_assistant_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;
  
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildWebLayout();
        }
        return _buildMobileLayout();
      },
    );
  }

  Widget _buildWebLayout() {
    final user = _authService.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: user != null 
            ? _firestore.collection('users').doc(user.uid).snapshots()
            : const Stream.empty(),
        builder: (context, snapshot) {
          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          final String displayName = userData?['name'] ?? user?.phoneNumber ?? 'Пользователь';
          final String? photoUrl = userData?['photoUrl'];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Action Bar
                Align(
                  alignment: Alignment.topRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _showConfirmDialog(
                      context,
                      title: 'Вы действительно хотите выйти из аккаунта?',
                      actionTitle: 'Выйти',
                      isDestructive: true,
                      onAction: () async {
                        await _authService.logout();
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context, 
                            AppRoutes.auth, 
                            (route) => false,
                          );
                        }
                      },
                    ),
                    icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 20),
                    label: const Text('Выйти из аккаунта', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE94E4E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Profile Info
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    shape: BoxShape.circle,
                    image: photoUrl != null 
                        ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: photoUrl == null 
                      ? const Icon(Icons.person, size: 60, color: Color(0xFF8E8E93))
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2EB),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'Подписка неактивна',
                    style: TextStyle(
                      color: Color(0xFFFA4E02),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                // Calendar Access Section
                Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder<List<AssistantAccess>>(
                        stream: _firestoreService.getAssistants(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final assistants = snapshot.data ?? [];
                          
                          if (assistants.isEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Доступ к календарю',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 100),
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.person_add_alt_1, size: 64, color: Color(0xFFDE642E)),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Подключите помощников к управлению\nсобытиями',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: 280,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                                clipBehavior: Clip.antiAlias,
                                                child: const SizedBox(
                                                  width: 400,
                                                  height: 500,
                                                  child: AddAssistantPage(),
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.add_circle, color: Colors.white, size: 18),
                                          label: const Text('Добавить помощников', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFDE642E),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Доступ к календарю',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                          clipBehavior: Clip.antiAlias,
                                          child: const SizedBox(
                                            width: 400,
                                            height: 500,
                                            child: AddAssistantPage(),
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add_circle, color: Colors.white, size: 18),
                                    label: const Text('Добавить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFDE642E),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                  assistants.length * 2 - 1, 
                                  (index) {
                                    if (index.isOdd) return _buildDashedDivider();
                                    final assistant = assistants[index ~/ 2];
                                    return _buildWebAssistantItem(
                                      role: assistant.role,
                                      name: assistant.assistantName,
                                      isFullAccess: assistant.role == 'Полные права',
                                      onDelete: () {
                                        _firestoreService.deleteAssistant(assistant.assistantId);
                                      },
                                      onEdit: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                            clipBehavior: Clip.antiAlias,
                                            child: const SizedBox(
                                              width: 400,
                                              height: 500,
                                              child: AddAssistantPage(),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildWebAssistantItem({
    required String role, 
    required String name, 
    required bool isFullAccess,
    VoidCallback? onDelete,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F5FF),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'И',
                style: TextStyle(
                  color: Color(0xFF007AFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: TextStyle(
                    color: isFullAccess ? const Color(0xFFFA4E02) : const Color(0xFF588DFF),
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Все события',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit ?? () {},
            icon: const Icon(Icons.edit, color: Color(0xFFFA4E02), size: 20),
          ),
          IconButton(
            onPressed: onDelete ?? () {},
            icon: const Icon(Icons.delete, color: Color(0xFFE94E4E), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFE5E5EA)),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildMobileLayout() {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: user != null 
                    ? _firestore.collection('users').doc(user.uid).snapshots()
                    : const Stream.empty(),
                builder: (context, snapshot) {
                  final userData = snapshot.data?.data() as Map<String, dynamic>?;
                  final String displayName = userData?['name'] ?? user?.phoneNumber ?? 'Пользователь';
                  final String? photoUrl = userData?['photoUrl'];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildUserInfoCard(displayName, photoUrl),
                        const SizedBox(height: 24),
                        _buildActionsList(),
                        const SizedBox(height: 12),
                        _buildActionCard(
                          title: 'Выйти из аккаунта',
                          onTap: () => _showConfirmDialog(
                            context,
                            title: 'Вы действительно хотите выйти из аккаунта?',
                            actionTitle: 'Выйти',
                            isDestructive: true,
                            onAction: () async {
                              await _authService.logout();
                              if (mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context, 
                                  AppRoutes.auth, 
                                  (route) => false,
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
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
                  );
                }
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
    if (kIsWeb || MediaQuery.of(context).size.width > 800) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDestructive ? const Color(0xFFDE642E).withOpacity(0.1) : const Color(0xFF0088FF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDestructive ? Icons.logout : Icons.info_outline,
                    size: 32,
                    color: isDestructive ? const Color(0xFFDE642E) : const Color(0xFF0088FF),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF7F6F2),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Отмена',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onAction();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDestructive ? const Color(0xFFDE642E) : const Color(0xFF0088FF),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          actionTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
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

  Widget _buildUserInfoCard(String name, String? photoUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
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
              image: photoUrl != null 
                  ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: photoUrl == null 
                ? const Icon(Icons.person, size: 60, color: Color(0xFF8E8E93))
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.assistants);
            },
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
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
