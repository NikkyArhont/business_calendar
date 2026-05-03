import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:file_picker/file_picker.dart';
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/core/services/firestore_service.dart';
import 'package:business_calendar/core/models/calendar_event.dart';
import 'package:business_calendar/config/constants/app_routes.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _firestoreService = FirestoreService();
  final _contactController = TextEditingController();
  final _titleController = TextEditingController();
  final _quillController = quill.QuillController.basic();
  final List<Map<String, dynamic>> _selectedContacts = [];
  final List<PlatformFile> _attachedFiles = [];
  List<Map<String, dynamic>> _allContacts = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  bool _isAllDay = false;
  bool _showStartCalendar = false;
  bool _showEndCalendar = false;
  DateTime _calendarMonth = DateTime.now();
  String _selectedRepeat = 'Никогда';
  String _selectedType = 'Не выбрано';
  Color _selectedColor = const Color(0xFFFA4E02);
  final GlobalKey _repeatKey = GlobalKey();
  final GlobalKey _typeKey = GlobalKey();
  final GlobalKey _colorKey = GlobalKey();
  final List<String> _painTags = [];
  final List<String> _solutionTags = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _contactController.addListener(_onSearchChanged);
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _contactController.dispose();
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  void _loadContacts() {
    _firestoreService.getContacts().listen((contacts) {
      if (mounted) {
        setState(() {
          _allContacts = contacts;
        });
      }
    });
  }

  void _saveEvent() async {
    setState(() => _isLoading = true);
    try {
      final event = CalendarEvent(
        id: '', // Firestore will generate ID
        title: _titleController.text.trim(),
        selectedContacts: _selectedContacts,
        startTime: _startDate,
        endTime: _endDate,
        isAllDay: _isAllDay,
        repeat: _selectedRepeat,
        type: _selectedType,
        colorValue: _selectedColor.value,
        clientPainPoints: _painTags,
        solutions: _solutionTags,
        note: jsonEncode(_quillController.document.toDelta().toJson()),
        fileUrls: _attachedFiles.map((f) => f.name).toList(), // Using names as placeholders
        createdAt: DateTime.now(),
      );

      await _firestoreService.addEvent(event);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при сохранении: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged() {
    final query = _contactController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _allContacts.where((contact) {
        final name = (contact['name'] as String? ?? '').toLowerCase();
        // Don't show if already selected
        final isSelected = _selectedContacts.any((c) => c['id'] == contact['id']);
        return name.contains(query) && !isSelected;
      }).toList();
    });
  }

  void _selectContact(Map<String, dynamic> contact) {
    setState(() {
      _selectedContacts.add(contact);
      _contactController.clear();
      _searchResults = [];
      _isSearching = false;
    });
  }

  void _removeContact(Map<String, dynamic> contact) {
    setState(() {
      _selectedContacts.removeWhere((c) => c['id'] == contact['id']);
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEE, d MMM', 'ru').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  void _onDateSelected(DateTime date, bool isStart) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (date.isBefore(today)) return;

    setState(() {
      if (isStart) {
        _startDate = DateTime(date.year, date.month, date.day, _startDate.hour, _startDate.minute);
        if (_startDate.isAfter(_endDate)) {
          _endDate = _startDate.add(const Duration(hours: 1));
        }
        _showStartCalendar = false;
      } else {
        _endDate = DateTime(date.year, date.month, date.day, _endDate.hour, _endDate.minute);
        if (_endDate.isBefore(_startDate)) {
          _startDate = _endDate.subtract(const Duration(hours: 1));
        }
        _showEndCalendar = false;
      }
    });
  }

  void _onTimeSelected(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startDate : _endDate),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = DateTime(_startDate.year, _startDate.month, _startDate.day, picked.hour, picked.minute);
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(hours: 1));
          }
        } else {
          _endDate = DateTime(_endDate.year, _endDate.month, _endDate.day, picked.hour, picked.minute);
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate.subtract(const Duration(hours: 1));
          }
        }
      });
    }
  }

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
          _isLoading 
            ? const Center(child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ))
            : TextButton(
                onPressed: _titleController.text.trim().isEmpty 
                  ? null 
                  : _saveEvent,
                child: Text(
                  'Сохранить',
                  style: TextStyle(
                    color: _titleController.text.trim().isEmpty 
                      ? Colors.grey 
                      : const Color(0xFF007AFF),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ФИО Контакта Section
                _buildSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _contactController,
                                decoration: const InputDecoration(
                                  hintText: 'ФИО контакта',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF8E8E93),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                final results = await Navigator.pushNamed(
                                  context,
                                  AppRoutes.selectContacts,
                                  arguments: {
                                    'initialSelectedIds': _selectedContacts
                                        .map((c) => c['id'] as String)
                                        .toList()
                                  },
                                );
                                if (results != null && results is List<Map<String, dynamic>>) {
                                  setState(() {
                                    _selectedContacts.clear();
                                    _selectedContacts.addAll(results);
                                  });
                                }
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFA4E02),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedContacts.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedContacts.map((contact) => _buildContactChip(contact)).toList(),
                          ),
                        ),
                      if (_isSearching && _searchResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: _searchResults.map((contact) {
                              return ListTile(
                                title: Text(contact['name'] ?? 'Без имени'),
                                subtitle: Text(contact['phone'] ?? ''),
                                onTap: () => _selectContact(contact),
                              );
                            }).toList(),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.addContact);
                          },
                          child: _buildActionButton(
                            icon: Icons.add,
                            label: 'Добавить контакт',
                            color: const Color(0xFFFA4E02),
                            backgroundColor: const Color(0x0FFA4E02),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDivider(),

                // Название события Section
                _buildSection(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: _titleController,
                      maxLength: 70,
                      decoration: const InputDecoration(
                        hintText: 'Краткое название события',
                        hintStyle: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                _buildDivider(),

                // Весь день Switch
                _buildSection(
                  child: _buildSwitchRow('Весь день', _isAllDay, (val) {
                    setState(() {
                      _isAllDay = val;
                    });
                  }),
                ),
                _buildDivider(),

                // Дата и время
                _buildSection(
                  child: Column(
                    children: [
                      _buildValueRow(
                        _formatDate(_startDate),
                        _formatTime(_startDate),
                        onDateTap: () {
                          setState(() {
                            _showStartCalendar = !_showStartCalendar;
                            _showEndCalendar = false;
                            _calendarMonth = _startDate;
                          });
                        },
                        onTimeTap: () => _onTimeSelected(true),
                      ),
                      if (_showStartCalendar) _buildCalendar(_startDate, (d) => _onDateSelected(d, true)),
                      const Divider(height: 1, indent: 16),
                      _buildValueRow(
                        _formatDate(_endDate),
                        _formatTime(_endDate),
                        onDateTap: () {
                          setState(() {
                            _showEndCalendar = !_showEndCalendar;
                            _showStartCalendar = false;
                            _calendarMonth = _endDate;
                          });
                        },
                        onTimeTap: () => _onTimeSelected(false),
                      ),
                      if (_showEndCalendar) _buildCalendar(_endDate, (d) => _onDateSelected(d, false)),
                    ],
                  ),
                ),
                _buildDivider(),

                // Повтор
                _buildSection(
                  child: GestureDetector(
                    key: _repeatKey,
                    onTap: _showRepeatMenu,
                    child: _buildSelectRow('Повтор', _selectedRepeat),
                  ),
                ),
                _buildDivider(),

                // Тип события
                _buildSection(
                  child: GestureDetector(
                    key: _typeKey,
                    onTap: _showTypeMenu,
                    child: _buildSelectRow('Тип события', _selectedType),
                  ),
                ),
                _buildDivider(),

                // Цвет события
                _buildSection(
                  child: GestureDetector(
                    key: _colorKey,
                    onTap: _showColorMenu,
                    child: _buildSelectRow(
                      'Цвет события', 
                      '', 
                      trailing: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                _buildDivider(),

                // Боль клиента
                _buildTagSection('Боль клиента, проблема, заключение', _painTags, (tag) {
                  setState(() => _painTags.add(tag));
                }, (tag) {
                  setState(() => _painTags.remove(tag));
                }),
                _buildDivider(),

                // Решение
                _buildTagSection('Решение, действие, манипуляция', _solutionTags, (tag) {
                  setState(() => _solutionTags.add(tag));
                }, (tag) {
                  setState(() => _solutionTags.remove(tag));
                }),
                _buildDivider(),

                // Заметка
                _buildSection(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        quill.QuillSimpleToolbar(
                          controller: _quillController,
                          config: const quill.QuillSimpleToolbarConfig(
                            showAlignmentButtons: false,
                            showCenterAlignment: false,
                            showJustifyAlignment: false,
                            showLeftAlignment: false,
                            showRightAlignment: false,
                            showListNumbers: false,
                            showListBullets: false,
                            showListCheck: false,
                            showCodeBlock: false,
                            showInlineCode: false,
                            showQuote: false,
                            showIndent: false,
                            showLink: false,
                            showUndo: true,
                            showRedo: true,
                            showSearchButton: false,
                            showSubscript: false,
                            showSuperscript: false,
                            showFontSize: false,
                            showFontFamily: false,
                            showBoldButton: true,
                            showItalicButton: true,
                            showUnderLineButton: true,
                            showStrikeThrough: false,
                            showColorButton: false,
                            showBackgroundColorButton: false,
                            showClearFormat: true,
                            showHeaderStyle: false,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 150,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFF2F2F7)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: quill.QuillEditor.basic(
                            controller: _quillController,
                            config: const quill.QuillEditorConfig(
                              placeholder: 'Добавьте заметку о встрече...',
                              expands: false,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Макс. 700 символов',
                            style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                          ),
                        ),
                      ],
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
                      if (_attachedFiles.isNotEmpty)
                        Column(
                          children: _attachedFiles.asMap().entries.map((entry) => _buildFileItem(entry.value, entry.key)).toList(),
                        ),
                      const SizedBox(height: 8),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _pickFiles,
                          borderRadius: BorderRadius.circular(10),
                          child: _buildActionButton(
                            icon: Icons.attach_file,
                            label: 'Файл',
                            color: Colors.white,
                            backgroundColor: const Color(0xFFFA4E02),
                          ),
                        ),
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

  Widget _buildContactChip(Map<String, dynamic> contact) {
    return GestureDetector(
      onTap: () => _removeContact(contact),
      child: Container(
        height: 32,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFF0088FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 6, left: 12, right: 8, bottom: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    contact['name'] ?? 'Имя контакта',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.43,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.close, color: Colors.white, size: 18),
                ],
              ),
            ),
          ],
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

  Widget _buildTagSection(String title, List<String> tags, Function(String) onAdd, Function(String) onRemove) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAddTagButton(onAdd),
              ...tags.map((tag) => _buildTag(tag, onRemove)),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAddTagButton(Function(String) onAdd) {
    return GestureDetector(
      onTap: () => _showAddTagDialog(onAdd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: ShapeDecoration(
          color: const Color(0xFFE8F3FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: Color(0xFF0088FF)),
            SizedBox(width: 4),
            Text(
              'Добавить',
              style: TextStyle(
                color: Color(0xFF0088FF),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTagDialog(Function(String) onAdd) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить тег', style: TextStyle(fontFamily: 'Inter')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Введите название...',
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFA4E02))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onAdd(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Добавить', style: TextStyle(color: Color(0xFFFA4E02))),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Function(String) onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: ShapeDecoration(
        color: const Color(0xFFFFF0E8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFFA4E02),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => onRemove(text),
            child: const Icon(
              Icons.close,
              size: 14,
              color: Color(0xFFFA4E02),
            ),
          ),
        ],
      ),
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

  Widget _buildSwitchRow(String label, bool value, Function(bool) onChanged) {
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
            onChanged: onChanged,
            activeColor: const Color(0xFFFA4E02),
          ),
        ],
      ),
    );
  }

  Widget _buildValueRow(String date, String time, {VoidCallback? onDateTap, VoidCallback? onTimeTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onDateTap,
              child: Text(
                date,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ),
          ),
          if (!_isAllDay)
            GestureDetector(
              onTap: onTimeTap,
              child: Text(
                time,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendar(DateTime selectedDate, Function(DateTime) onDateSelected) {
    final firstDayOfMonth = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final lastDayOfMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday; // 1 (Mon) to 7 (Sun)

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.symmetric(horizontal: BorderSide(color: Color(0xFFF2F2F7), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month/Year Picker
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Color(0xFFFA4E02)),
                        onPressed: () {
                          setState(() {
                            _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1);
                          });
                        },
                      ),
                      Text(
                        DateFormat('MMM', 'ru').format(_calendarMonth),
                        style: const TextStyle(color: Color(0xFFFA4E02), fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Color(0xFFFA4E02)),
                        onPressed: () {
                          setState(() {
                            _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Color(0xFFFA4E02)),
                        onPressed: () {
                          setState(() {
                            _calendarMonth = DateTime(_calendarMonth.year - 1, _calendarMonth.month);
                          });
                        },
                      ),
                      Text(
                        DateFormat('yyyy', 'ru').format(_calendarMonth),
                        style: const TextStyle(color: Color(0xFFFA4E02), fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Color(0xFFFA4E02)),
                        onPressed: () {
                          setState(() {
                            _calendarMonth = DateTime(_calendarMonth.year + 1, _calendarMonth.month);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Weekdays
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['П', 'В', 'С', 'Ч', 'П', 'С', 'В'].map((d) {
                return Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: (d == 'С' || d == 'В') && ['П', 'В', 'С', 'Ч', 'П', 'С', 'В'].indexOf(d) > 4 
                          ? const Color(0xFF8E8E93) 
                          : Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Days grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 42, // 6 weeks
              itemBuilder: (context, index) {
                final dayOffset = index - (firstWeekday - 1);
                if (dayOffset < 0 || dayOffset >= daysInMonth) {
                  return const SizedBox.shrink();
                }

                final date = DateTime(_calendarMonth.year, _calendarMonth.month, dayOffset + 1);
                final isSelected = date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day;
                final isFuture = !date.isBefore(today);

                return GestureDetector(
                  onTap: isFuture ? () => onDateSelected(date) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFA4E02).withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: const Color(0xFFFA4E02), width: 1) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected 
                            ? const Color(0xFFFA4E02) 
                            : (isFuture ? Colors.black : const Color(0xFF8E8E93)),
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
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



  _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFF2F2F7));
  }

  void _showColorMenu() {
    final Map<String, Color> colorOptions = {
      'Красный': Colors.red,
      'Оранжевый': const Color(0xFFFA4E02),
      'Желтый': Colors.yellow,
      'Зеленый': Colors.green,
      'Мятный': const Color(0xFF00C7BE),
      'Голубой': const Color(0xFF32ADE6),
      'Синий': Colors.blue,
      'Индиго': Colors.indigo,
      'Фиолетовый': Colors.purple,
      'Розовый': Colors.pink,
      'Коричневый': Colors.brown,
      'Бежевый': const Color(0xFFD2B48C), // Tan/Beige
      'Серый': Colors.grey,
    };

    _showCustomMenu(
      key: _colorKey,
      options: colorOptions.keys.toList(),
      onSelected: (val) => setState(() => _selectedColor = colorOptions[val]!),
      height: 336,
      itemBuilder: (text) => Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: colorOptions[text],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRepeatMenu() {
    _showCustomMenu(
      key: _repeatKey,
      options: ['Никогда', 'Каждый день', 'Каждую неделю', 'Ежемесячно', 'Ежегодно'],
      onSelected: (val) => setState(() => _selectedRepeat = val),
    );
  }

  void _showTypeMenu() {
    _showCustomMenu(
      key: _typeKey,
      options: ['Личная', 'Рабочая'],
      onSelected: (val) => setState(() => _selectedType = val),
    );
  }

  void _showCustomMenu({
    required GlobalKey key,
    required List<String> options,
    required Function(String) onSelected,
    Widget Function(String)? itemBuilder,
    double? height,
  }) {
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final offset = renderBox.localToGlobal(Offset.zero);
    final topPosition = offset.dy + renderBox.size.height;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned(
            top: topPosition,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 208,
                height: height,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x0C343434),
                      blurRadius: 20,
                      offset: Offset(0, -2),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: options.map((opt) => _buildMenuItem(opt, onSelected, itemBuilder)).toList(),
                        ),
                      ),
                    ),
                    if (height != null) ...[
                      Container(
                        width: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F6F2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() {
          _attachedFiles.addAll(result.files);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выбор файлов отменен')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе файлов: $e')),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 Б";
    const suffixes = ["Б", "КБ", "МБ", "ГБ"];
    var i = (Math.log(bytes) / Math.log(1024)).floor();
    return ((bytes / Math.pow(1024, i)).toStringAsFixed(1)) + ' ' + suffixes[i];
  }

  Widget _buildFileItem(PlatformFile file, int index) {
    final isImage = ['jpg', 'jpeg', 'png', 'gif'].contains(file.extension?.toLowerCase());
    final isVideo = ['mp4', 'mov', 'avi'].contains(file.extension?.toLowerCase());

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          if (isImage || isVideo) {
            _showFilePreview(file);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: ShapeDecoration(
            color: const Color(0x0FFA4E02),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      child: Icon(
                        isImage ? Icons.image : (isVideo ? Icons.videocam : Icons.insert_drive_file),
                        color: const Color(0xFFFA4E02),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFFA4E02),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatFileSize(file.size),
                            style: const TextStyle(
                              color: Color(0xFFFA4E02),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFFFA4E02), size: 18),
                onPressed: () {
                  setState(() {
                    _attachedFiles.removeAt(index);
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilePreview(PlatformFile file) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(file.name),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (file.bytes != null)
              Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                child: Image.memory(file.bytes!),
              )
            else
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Предпросмотр недоступен'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String text, Function(String) onSelected, Widget Function(String)? itemBuilder) {
    return InkWell(
      onTap: () {
        onSelected(text);
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: const BoxDecoration(color: Colors.white),
        child: Container(
          width: double.infinity,
          height: 44,
          padding: const EdgeInsets.all(12),
          child: itemBuilder != null 
              ? itemBuilder(text)
              : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
        ),
      ),
    );
  }
}

class _Tag {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData? icon;

  _Tag({required this.label, required this.color, required this.bgColor, this.icon});
}
