import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:business_calendar/core/services/firestore_service.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  // Контроллеры для ФИО
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  
  // Дата рождения
  final _birthdayController = TextEditingController();
  
  // Пол
  String? _selectedGender;
  bool _showGenderPicker = false;
  
  // Контакты
  final List<TextEditingController> _phoneControllers = [TextEditingController()];
  final _emailController = TextEditingController();
  
  // Работа
  final _jobPlaceController = TextEditingController();
  final _departmentController = TextEditingController();
  final _professionController = TextEditingController();
  
  // Статус и Откуда пришел
  final _statusController = TextEditingController();
  final _sourceController = TextEditingController();
  
  // Доверенное лицо
  final _trustedNameController = TextEditingController();
  final _trustedPhoneController = TextEditingController();
  
  // Адрес и Описание
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _birthdayController.dispose();
    for (var controller in _phoneControllers) {
      controller.dispose();
    }
    _emailController.dispose();
    _jobPlaceController.dispose();
    _departmentController.dispose();
    _professionController.dispose();
    _statusController.dispose();
    _sourceController.dispose();
    _trustedNameController.dispose();
    _trustedPhoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    
    if (firstName.isEmpty && lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите имя или фамилию контакта')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = '$firstName $lastName'.trim();
      final phones = _phoneControllers
          .map((c) => c.text.trim())
          .where((p) => p.isNotEmpty)
          .toList();

      final contactData = {
        'firstName': firstName,
        'lastName': lastName,
        'middleName': _middleNameController.text.trim(),
        'name': name,
        'gender': _selectedGender,
        'birthday': _birthdayController.text.trim(),
        'phones': phones,
        'email': _emailController.text.trim(),
        'jobPlace': _jobPlaceController.text.trim(),
        'department': _departmentController.text.trim(),
        'profession': _professionController.text.trim(),
        'status': _statusController.text.trim(),
        'source': _sourceController.text.trim(),
        'trustedPerson': {
          'name': _trustedNameController.text.trim(),
          'phone': _trustedPhoneController.text.trim(),
        },
        'address': _addressController.text.trim(),
        'description': _descriptionController.text.trim(),
      };

      await _firestoreService.addContact(contactData);
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: _buildAppBar(),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                // ФИО
                _buildSection(
                  title: 'Имя контакта',
                  children: [
                    _buildTextField(hint: 'Имя', controller: _firstNameController),
                    _buildDivider(),
                    _buildTextField(hint: 'Фамилия', controller: _lastNameController),
                    _buildDivider(),
                    _buildTextField(hint: 'Отчество', controller: _middleNameController),
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
                      controller: _birthdayController,
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
                    _buildTextField(
                      controller: _emailController,
                      hint: 'Email', 
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Сведения о работе
                _buildSection(
                  title: 'Сведения о работе',
                  children: [
                    _buildTextField(hint: 'Место работы', controller: _jobPlaceController),
                    _buildDivider(),
                    _buildTextField(hint: 'Отдел', controller: _departmentController),
                    _buildDivider(),
                    _buildTextField(hint: 'Профессия', controller: _professionController),
                  ],
                ),
                const SizedBox(height: 12),

                // Статус контакта
                _buildSection(
                  title: 'Статус контакта',
                  children: [
                    _buildTextField(hint: 'Например, клиент', controller: _statusController),
                  ],
                ),
                const SizedBox(height: 12),

                // Откуда пришел клиент
                _buildSection(
                  title: 'Откуда пришел клиент',
                  children: [
                    _buildTextField(hint: 'Например, узнал от друзей', controller: _sourceController),
                  ],
                ),
                const SizedBox(height: 12),

                // Контакты доверенного лица
                _buildSection(
                  title: 'Контакты доверенного лица',
                  children: [
                    _buildTextField(hint: 'ФИО', controller: _trustedNameController),
                    _buildDivider(),
                    _buildTextField(
                      hint: 'Номер телефона', 
                      controller: _trustedPhoneController,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Адрес
                _buildSection(
                  title: 'Адрес',
                  children: [
                    _buildTextField(hint: 'Город, улица, дом, квартира', controller: _addressController),
                  ],
                ),
                const SizedBox(height: 12),

                // Описание
                _buildSection(
                  title: 'Описание',
                  children: [
                    _buildTextField(
                      controller: _descriptionController,
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
      leadingWidth: 100,
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
          onPressed: _isLoading ? null : _saveContact,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              'Сохранить',
              style: TextStyle(
                color: _isLoading ? Colors.grey : const Color(0xFF007AFF),
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
