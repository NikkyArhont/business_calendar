import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  String? _selectedGender;
  bool _showGenderPicker = false;
  final List<TextEditingController> _phoneControllers = [TextEditingController()];

  @override
  void dispose() {
    for (var controller in _phoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // ФИО
            _buildSection(
              title: 'Имя контакта',
              children: [
                _buildTextField(hint: 'Имя'),
                _buildDivider(),
                _buildTextField(hint: 'Фамилия'),
                _buildDivider(),
                _buildTextField(hint: 'Отчество'),
              ],
            ),
            const SizedBox(height: 12),

            // Пол
            _buildSection(
              title: 'Пол',
              children: [
                GestureDetector(
                  onTap: () => setState(() => _showGenderPicker = !_showGenderPicker),
                  child: _buildTextField(
                    hint: 'Укажите пол',
                    enabled: false,
                    value: _selectedGender,
                    suffix: Icon(
                      _showGenderPicker ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ),
                if (_showGenderPicker) ...[
                  const SizedBox(height: 8),
                  _GenderActionList(
                    onSelected: (gender) {
                      setState(() {
                        _selectedGender = gender;
                        _showGenderPicker = false;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // ДР
            _buildSection(
              title: 'Дата рождения',
              children: [
                _buildTextField(
                  hint: '##.##.####',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    DateInputFormatter(),
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Контакты
            _buildSection(
              title: 'Контакты',
              children: [
                ..._phoneControllers.asMap().entries.map((entry) {
                  return Column(
                    children: [
                      _buildTextField(
                        controller: entry.value,
                        hint: 'Номер телефона',
                        keyboardType: TextInputType.phone,
                      ),
                      if (entry.key < _phoneControllers.length - 1) _buildDivider(),
                    ],
                  );
                }),
                _buildAddButton(
                  label: 'Добавить номер',
                  onTap: () {
                    setState(() {
                      _phoneControllers.add(TextEditingController());
                    });
                  },
                ),
                _buildDivider(),
                _buildTextField(hint: 'Email', keyboardType: TextInputType.emailAddress),
              ],
            ),
            const SizedBox(height: 12),

            // Сведения о работе
            _buildSection(
              title: 'Сведения о работе',
              children: [
                _buildTextField(hint: 'Место работы'),
                _buildDivider(),
                _buildTextField(hint: 'Отдел'),
                _buildDivider(),
                _buildTextField(hint: 'Профессия'),
              ],
            ),
            const SizedBox(height: 12),

            // Статус контакта
            _buildSection(
              title: 'Статус контакта',
              children: [
                _buildTextField(hint: 'Например, клиент'),
              ],
            ),
            const SizedBox(height: 12),

            // Откуда пришел клиент
            _buildSection(
              title: 'Откуда пришел клиент',
              children: [
                _buildTextField(hint: 'Например, узнал от друзей'),
              ],
            ),
            const SizedBox(height: 12),

            // Контакты доверенного лица
            _buildSection(
              title: 'Контакты доверенного лица',
              children: [
                _buildTextField(hint: 'ФИО'),
                _buildDivider(),
                _buildTextField(hint: 'Номер телефона', keyboardType: TextInputType.phone),
              ],
            ),
            const SizedBox(height: 12),

            // Адрес
            _buildSection(
              title: 'Адрес',
              children: [
                _buildTextField(hint: 'Город, улица, дом, квартира'),
              ],
            ),
            const SizedBox(height: 12),

            // Описание
            _buildSection(
              title: 'Описание',
              children: [
                _buildTextField(
                  hint: 'Заметки о контакте...',
                  maxLines: 4,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Файлы
            _buildSection(
              title: 'Файлы',
              children: [
                _buildAddButton(
                  label: 'Добавить файл',
                  icon: Icons.attach_file,
                  onTap: () {
                    // Логика подгрузки файлов
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.75),
      elevation: 0,
      leadingWidth: 100, // For Cancel
      leading: TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(
          'Отмена',
          style: TextStyle(
            color: Color(0xFF007AFF),
            fontSize: 17,
            fontFamily: 'SF Pro',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Text(
              'Сохранить',
              style: TextStyle(
                color: Color(0xFF007AFF),
                fontSize: 17,
                fontFamily: 'SF Pro',
              ),
            ),
          ),
        ),
      ],
      title: const SizedBox.shrink(),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String hint,
    TextEditingController? controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
    String? value,
    Widget? suffix,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: enabled
                ? TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    maxLines: maxLines,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    value ?? hint,
                    style: TextStyle(
                      color: value != null ? Colors.black : const Color(0xFF8E8E93),
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                  ),
          ),
          if (suffix != null) suffix,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF2F2F7));
  }

  Widget _buildAddButton({
    required String label,
    required VoidCallback onTap,
    IconData icon = Icons.add_circle,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFA4E02), size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFFA4E02),
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderActionList extends StatelessWidget {
  final Function(String) onSelected;
  const _GenderActionList({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildItem('Мужчина'),
        const Divider(height: 1, indent: 16, endIndent: 16),
        _buildItem('Женщина'),
      ],
    );
  }

  Widget _buildItem(String label) {
    return InkWell(
      onTap: () => onSelected(label),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.length > oldValue.text.length) {
      if (text.length == 2 || text.length == 5) {
        return TextEditingValue(
          text: '$text.',
          selection: TextSelection.collapsed(offset: text.length + 1),
        );
      }
    }
    return newValue;
  }
}
