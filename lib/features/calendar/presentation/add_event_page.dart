import 'package:flutter/material.dart';
import 'package:business_calendar/config/constants/app_colors.dart';

class AddEventPage extends StatelessWidget {
  const AddEventPage({super.key});

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
            softWrap: false,
            style: TextStyle(
              color: Color(0xFF007AFF),
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        leadingWidth: 100,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement save logic
              Navigator.pop(context);
            },
            child: const Text(
              'Сохранить',
              style: TextStyle(
                color: Color(0xFF007AFF),
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
        centerTitle: true,
        title: const Text(
          '',
          style: TextStyle(color: Colors.black),
        ),
        shape: const Border(
          bottom: BorderSide(color: Color(0x4C3C3C43), width: 0.33),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ФИО Контакта Section
                _buildSection(
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'ФИО контакта',
                        trailing: const Icon(Icons.person_outline, color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _buildActionButton(
                          icon: Icons.add,
                          label: 'Добавить контакт',
                          color: const Color(0xFFFA4E02),
                          backgroundColor: const Color(0x0FFA4E02),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDivider(),

                // Название события Section
                _buildSection(
                  child: _buildTextField(label: 'Краткое название события'),
                ),
                _buildDivider(),

                // Весь день Switch
                _buildSection(
                  child: _buildSwitchRow('Весь день', false),
                ),
                _buildDivider(),

                // Дата и время
                _buildSection(
                  child: Column(
                    children: [
                      _buildValueRow('Сб, 21 февр', '18:00'),
                      const Divider(height: 1, indent: 16),
                      _buildValueRow('Сб, 21 февр', '19:00'),
                    ],
                  ),
                ),
                _buildDivider(),

                // Повтор
                _buildSection(
                  child: _buildSelectRow('Повтор', 'Никогда'),
                ),
                _buildDivider(),

                // Тип события
                _buildSection(
                  child: _buildSelectRow('Тип события', 'Не выбрано'),
                ),
                _buildDivider(),

                // Цвет события
                _buildSection(
                  child: _buildSelectRow('Цвет события', '', trailing: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFA4E02),
                      shape: BoxShape.circle,
                    ),
                  )),
                ),
                _buildDivider(),

                // Боль клиента
                _buildSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(label: 'Боль клиента, проблема, заключение', fontSize: 16),
                      _buildTagsRow([
                        _Tag(label: 'Добавить', color: const Color(0xFF0088FF), bgColor: const Color(0x0F0088FF), icon: Icons.add),
                        _Tag(label: 'Правая нога', color: const Color(0xFFFA4E02), bgColor: const Color(0x0FFA4E02)),
                        _Tag(label: 'Левая рука', color: const Color(0xFFFA4E02), bgColor: const Color(0x0FFA4E02)),
                      ]),
                    ],
                  ),
                ),
                _buildDivider(),

                // Решение
                _buildSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(label: 'Решение, действие, манипуляция', fontSize: 16),
                      _buildTagsRow([
                        _Tag(label: 'Добавить', color: const Color(0xFF0088FF), bgColor: const Color(0x0F0088FF), icon: Icons.add),
                        _Tag(label: 'Правая нога', color: const Color(0xFFFA4E02), bgColor: const Color(0x0FFA4E02)),
                        _Tag(label: 'Левая рука', color: const Color(0xFFFA4E02), bgColor: const Color(0x0FFA4E02)),
                      ]),
                    ],
                  ),
                ),
                _buildDivider(),

                // Заметка
                _buildSection(
                  child: Container(
                    height: 120,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    alignment: Alignment.topLeft,
                    child: const Text(
                      'Добавьте заметку о встрече',
                      style: TextStyle(color: Color(0xFF8E8E93), fontSize: 16),
                    ),
                  ),
                ),
                _buildDivider(),

                // Файлы
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Файлы',
                        style: TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildActionButton(
                        icon: Icons.attach_file,
                        label: 'Файл',
                        color: Colors.white,
                        backgroundColor: const Color(0xFFFA4E02),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Добавьте фото, видео или файл',
                        style: TextStyle(
                          color: Color(0x99000000),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required Widget child}) {
    return Container(
      width: double.infinity,
      child: child,
    );
  }

  Widget _buildTextField({required String label, Widget? trailing, double fontSize = 20}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF8E8E93),
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {},
            activeColor: const Color(0xFFFA4E02),
          ),
        ],
      ),
    );
  }

  Widget _buildValueRow(String date, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              date,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFA4E02),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          trailing ?? const Icon(Icons.chevron_right, color: Color(0xFFFA4E02), size: 16),
        ],
      ),
    );
  }

  Widget _buildTagsRow(List<_Tag> tags) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags.map((tag) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: tag.bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tag.icon != null) ...[
                Icon(tag.icon, color: tag.color, size: 16),
                const SizedBox(width: 4),
              ],
              Text(
                tag.label,
                style: TextStyle(
                  color: tag.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFF2F2F7));
  }
}

class _Tag {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData? icon;

  _Tag({required this.label, required this.color, required this.bgColor, this.icon});
}
