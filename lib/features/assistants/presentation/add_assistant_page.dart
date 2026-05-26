import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/config/constants/app_routes.dart';
import 'package:business_calendar/shared/widgets/app_primary_button.dart';
import 'package:business_calendar/features/assistants/presentation/qr_share_page.dart';

class AddAssistantPage extends StatefulWidget {
  const AddAssistantPage({super.key});

  @override
  State<AddAssistantPage> createState() => _AddAssistantPageState();
}

class _AddAssistantPageState extends State<AddAssistantPage> {
  String _selectedAccess = 'Все события';
  String _selectedRights = 'Полные права';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Отмена',
            style: TextStyle(
              color: Color(0xFFFA4E02),
              fontSize: 17,
              fontFamily: 'Inter',
            ),
          ),
        ),
        leadingWidth: 100,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // Карточка настроек
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  title: 'Доступ',
                  value: _selectedAccess,
                  isMenu: true,
                  onSelected: (value) {
                    setState(() => _selectedAccess = value);
                  },
                  menuItems: ['Все события', 'Только рабочие'],
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildSettingsTile(
                  title: 'Права',
                  value: _selectedRights,
                  isMenu: true,
                  onSelected: (value) {
                    setState(() => _selectedRights = value);
                  },
                  menuItems: ['Читатель', 'Редактор', 'Полные права'],
                ),
              ],
            ),
          ),
          const Spacer(),
          // Кнопка Поделиться
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppPrimaryButton(
              text: 'Поделиться',
              onPressed: () {
                if (kIsWeb) {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      clipBehavior: Clip.antiAlias,
                      child: const SizedBox(
                        width: 400,
                        height: 500,
                        child: QrSharePage(),
                      ),
                    ),
                  );
                } else {
                  Navigator.pushNamed(context, AppRoutes.qrShare);
                }
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String value,
    bool isMenu = false,
    Function(String)? onSelected,
    List<String>? menuItems,
  }) {
    final tileContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
          ),
          if (isMenu)
            PopupMenuButton<String>(
              onSelected: onSelected,
              offset: const Offset(0, 30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              itemBuilder: (context) => menuItems!.map((item) => PopupMenuItem(
                value: item,
                height: 44, // Высота из вашего кода
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              )).toList(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFFFA4E02),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFFA4E02),
                    size: 20,
                  ),
                ],
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFFA4E02),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
        ],
      ),
    );

    return tileContent;
  }
}
