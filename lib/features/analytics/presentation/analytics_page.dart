import 'package:flutter/material.dart';
import 'package:business_calendar/shared/widgets/app_primary_button.dart';
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/config/constants/app_routes.dart';
import 'package:business_calendar/features/analytics/presentation/analytics_results_page.dart';
import 'package:business_calendar/features/analytics/presentation/tag_selection_page.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  RangeValues _ageRange = const RangeValues(30, 80);
  bool _isMaleSelected = true;
  bool _isFemaleSelected = true;
  final TextEditingController _eventNameController = TextEditingController();
  bool _showWebResults = false;
  
  // Tag States
  List<String> _selectedStatuses = [];
  List<String> _selectedSources = [];
  List<String> _selectedProfessions = [];
  List<String> _selectedRegions = [];
  List<String> _selectedPains = [];
  List<String> _selectedSolutions = [];

  // Available Tags (Mock Data)
  final List<String> _availableStatuses = ['Клиент', 'Новый', 'В работе', 'Завершен'];
  final List<String> _availableSources = ['Узнал от друзей', 'Instagram', 'Facebook', 'Google'];
  final List<String> _availableProfessions = ['IT', 'Маркетинг', 'Продажи', 'Дизайн'];
  final List<String> _availableRegions = ['Москва', 'Московская область', 'СПб', 'Казань'];
  final List<String> _availablePains = ['Боль 1', 'Боль 2', 'Нет времени', 'Дорого'];
  final List<String> _availableSolutions = ['Решение 1', 'Решение 2', 'Консультация', 'Обучение'];

  // Date Selection State
  DateTime _focusedDate = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showMonthPicker = false;
  bool _showYearPicker = false;
  bool _isCalendarOpen = false;

  void _resetDates() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _isCalendarOpen = false;
    });
  }

  final List<String> _months = [
    'Янв', 'Февр', 'Март', 'Апр', 'Май', 'Июнь',
    'Июль', 'Авг', 'Сент', 'Окт', 'Нояб', 'Дек'
  ];

  String _formatDate(DateTime? date) {
    if (date == null) return '__.__.____';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _onDateTap(DateTime date) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = date;
        _endDate = null;
      } else if (_startDate != null && _endDate == null) {
        if (date.isBefore(_startDate!)) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      }
    });
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _getFirstWeekdayOffset(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday - 1;
  }

  Future<void> _navigateToTagSelection({
    required String title,
    required List<String> selectedTags,
    required List<String> availableTags,
    required Function(List<String>) onResult,
  }) async {
    final isWeb = MediaQuery.of(context).size.width > 800;
    
    dynamic result;
    if (isWeb) {
      result = await showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 400,
            height: 600,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TagSelectionPage(
              title: title,
              initialSelectedTags: selectedTags,
              availableTags: availableTags,
            ),
          ),
        ),
      );
    } else {
      result = await Navigator.pushNamed(
        context,
        AppRoutes.tagSelection,
        arguments: {
          'title': title,
          'initialSelectedTags': selectedTags,
          'availableTags': availableTags,
        },
      );
    }

    if (result != null && result is List<String>) {
      onResult(result);
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    super.dispose();
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Левая панель с фильтрами
          Container(
            width: 320,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Color(0xFFE6E8EC)),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAgeSection(),
                  const SizedBox(height: 12),
                  _buildGenderSection(),
                  const SizedBox(height: 12),
                  _buildTextFieldSection(title: 'Название события', controller: _eventNameController),
                  const SizedBox(height: 12),
                  _buildTagSection(
                    title: 'Статус',
                    selectedTags: _selectedStatuses,
                    tagColor: const Color(0xFFFA4E02),
                    onAddTap: () => _navigateToTagSelection(
                      title: 'Статус',
                      selectedTags: _selectedStatuses,
                      availableTags: _availableStatuses,
                      onResult: (tags) => setState(() => _selectedStatuses = tags),
                    ),
                    onDeleteTag: (tag) => setState(() => _selectedStatuses.remove(tag)),
                  ),
                  const SizedBox(height: 12),
                  _buildPeriodSection(),
                  const SizedBox(height: 12),
                  _buildTagSection(
                    title: 'Откуда пришел, источник рекламы',
                    selectedTags: _selectedSources,
                    tagColor: const Color(0xFF588DFF),
                    onAddTap: () => _navigateToTagSelection(
                      title: 'Источник рекламы',
                      selectedTags: _selectedSources,
                      availableTags: _availableSources,
                      onResult: (tags) => setState(() => _selectedSources = tags),
                    ),
                    onDeleteTag: (tag) => setState(() => _selectedSources.remove(tag)),
                  ),
                  const SizedBox(height: 12),
                  _buildTextFieldSection(title: 'Профессия', controller: TextEditingController(text: 'Название профессии')),
                  const SizedBox(height: 12),
                  _buildTagSection(
                    title: 'Регион',
                    selectedTags: _selectedRegions,
                    tagColor: const Color(0xFF588DFF),
                    onAddTap: () => _navigateToTagSelection(
                      title: 'Регион',
                      selectedTags: _selectedRegions,
                      availableTags: _availableRegions,
                      onResult: (tags) => setState(() => _selectedRegions = tags),
                    ),
                    onDeleteTag: (tag) => setState(() => _selectedRegions.remove(tag)),
                  ),
                  const SizedBox(height: 12),
                  _buildTagSection(
                    title: 'Боль клиента',
                    selectedTags: _selectedPains,
                    tagColor: const Color(0xFFFA4E02),
                    onAddTap: () => _navigateToTagSelection(
                      title: 'Боль клиента',
                      selectedTags: _selectedPains,
                      availableTags: _availablePains,
                      onResult: (tags) => setState(() => _selectedPains = tags),
                    ),
                    onDeleteTag: (tag) => setState(() => _selectedPains.remove(tag)),
                  ),
                  const SizedBox(height: 12),
                  _buildTagSection(
                    title: 'Решение',
                    selectedTags: _selectedSolutions,
                    tagColor: const Color(0xFF6A5AE0),
                    onAddTap: () => _navigateToTagSelection(
                      title: 'Решение',
                      selectedTags: _selectedSolutions,
                      availableTags: _availableSolutions,
                      onResult: (tags) => setState(() => _selectedSolutions = tags),
                    ),
                    onDeleteTag: (tag) => setState(() => _selectedSolutions.remove(tag)),
                  ),
                  const SizedBox(height: 32),
                  AppPrimaryButton(
                    text: 'Показать аналитику',
                    onPressed: () {
                      setState(() {
                        _showWebResults = true;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Правая основная область
          Expanded(
            child: Container(
              color: Colors.white,
              child: _showWebResults
                  ? AnalyticsResultsPage(
                      isWebModule: true,
                      filters: {
                        'ageRange': _ageRange,
                        'isMaleSelected': _isMaleSelected,
                        'isFemaleSelected': _isFemaleSelected,
                        'profession': _eventNameController.text,
                        'statuses': _selectedStatuses,
                        'sources': _selectedSources,
                        'regions': _selectedRegions,
                        'pains': _selectedPains,
                        'solutions': _selectedSolutions,
                      },
                    )
                  : _buildWebEmptyState(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pie_chart, size: 80, color: Color(0xFFFA4E02)),
          const SizedBox(height: 24),
          const Text(
            'Введите параметры, чтобы отобразить\nаналитику',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1C1B1F),
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Аналитика',
          style: TextStyle(
            color: Color(0xFF1C1B1F),
            fontSize: 22,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            _buildAgeSection(),
            const SizedBox(height: 12),
            _buildGenderSection(),
            const SizedBox(height: 12),
            _buildTextFieldSection(title: 'Название события', controller: _eventNameController),
            const SizedBox(height: 12),
            _buildTagSection(
              title: 'Статус',
              selectedTags: _selectedStatuses,
              tagColor: const Color(0xFFFA4E02),
              onAddTap: () => _navigateToTagSelection(
                title: 'Статус',
                selectedTags: _selectedStatuses,
                availableTags: _availableStatuses,
                onResult: (tags) => setState(() => _selectedStatuses = tags),
              ),
              onDeleteTag: (tag) => setState(() => _selectedStatuses.remove(tag)),
            ),
            const SizedBox(height: 12),
            _buildPeriodSection(),
            const SizedBox(height: 12),
            _buildTagSection(
              title: 'Откуда пришел, источник рекламы',
              selectedTags: _selectedSources,
              tagColor: const Color(0xFF588DFF),
              onAddTap: () => _navigateToTagSelection(
                title: 'Источник рекламы',
                selectedTags: _selectedSources,
                availableTags: _availableSources,
                onResult: (tags) => setState(() => _selectedSources = tags),
              ),
              onDeleteTag: (tag) => setState(() => _selectedSources.remove(tag)),
            ),
            const SizedBox(height: 12),
            _buildTextFieldSection(title: 'Профессия', controller: TextEditingController(text: 'Название профессии')),
            const SizedBox(height: 12),
            _buildTagSection(
              title: 'Регион',
              selectedTags: _selectedRegions,
              tagColor: const Color(0xFF588DFF),
              onAddTap: () => _navigateToTagSelection(
                title: 'Регион',
                selectedTags: _selectedRegions,
                availableTags: _availableRegions,
                onResult: (tags) => setState(() => _selectedRegions = tags),
              ),
              onDeleteTag: (tag) => setState(() => _selectedRegions.remove(tag)),
            ),
            const SizedBox(height: 12),
            _buildTagSection(
              title: 'Боль клиента',
              selectedTags: _selectedPains,
              tagColor: const Color(0xFFFA4E02),
              onAddTap: () => _navigateToTagSelection(
                title: 'Боль клиента',
                selectedTags: _selectedPains,
                availableTags: _availablePains,
                onResult: (tags) => setState(() => _selectedPains = tags),
              ),
              onDeleteTag: (tag) => setState(() => _selectedPains.remove(tag)),
            ),
            const SizedBox(height: 12),
            _buildTagSection(
              title: 'Решение',
              selectedTags: _selectedSolutions,
              tagColor: const Color(0xFF6A5AE0),
              onAddTap: () => _navigateToTagSelection(
                title: 'Решение',
                selectedTags: _selectedSolutions,
                availableTags: _availableSolutions,
                onResult: (tags) => setState(() => _selectedSolutions = tags),
              ),
              onDeleteTag: (tag) => setState(() => _selectedSolutions.remove(tag)),
            ),
            const SizedBox(height: 32),
            AppPrimaryButton(
              text: 'Показать аналитику',
              onPressed: () {
                final filters = {
                  'ageRange': _ageRange,
                  'isMaleSelected': _isMaleSelected,
                  'isFemaleSelected': _isFemaleSelected,
                  'profession': _eventNameController.text, // Используем поле для события/профессии
                  'statuses': _selectedStatuses,
                  'sources': _selectedSources,
                  'regions': _selectedRegions,
                  'pains': _selectedPains,
                  'solutions': _selectedSolutions,
                };
                Navigator.pushNamed(
                  context,
                  AppRoutes.analyticsResults,
                  arguments: {'filters': filters},
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeSection() {
    return _buildSection(
      title: 'Возраст',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final startX = (_ageRange.start / 100) * width;
              final endX = (_ageRange.end / 100) * width;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 32),
                  SizedBox(
                    width: width,
                    height: 58,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: SizedBox(
                            width: width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(11, (index) {
                                return Opacity(
                                  opacity: 0.20,
                                  child: Text(
                                    '${index * 10}',
                                    style: const TextStyle(color: Colors.black, fontSize: 10, fontFamily: 'Inter'),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 30.5,
                          child: Container(
                            width: width,
                            height: 4,
                            decoration: BoxDecoration(color: const Color(0xFFF7F6F2), borderRadius: BorderRadius.circular(100)),
                          ),
                        ),
                        Positioned(
                          left: startX,
                          top: 30.5,
                          child: Container(
                            width: (endX - startX).clamp(0, width),
                            height: 4,
                            decoration: BoxDecoration(color: const Color(0xFFFA4E02), borderRadius: BorderRadius.circular(100)),
                          ),
                        ),
                        _buildSliderHandle(startX, _ageRange.start.toInt().toString(), true),
                        _buildSliderHandle(endX, _ageRange.end.toInt().toString(), false),
                        Positioned(
                          left: -12,
                          right: -12,
                          top: 18,
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 0,
                              activeTrackColor: Colors.transparent,
                              inactiveTrackColor: Colors.transparent,
                              thumbColor: Colors.transparent,
                              overlayColor: Colors.transparent,
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: RangeSlider(
                              values: _ageRange,
                              min: 0,
                              max: 100,
                              divisions: 100,
                              onChanged: (values) => setState(() => _ageRange = values),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSliderHandle(double x, String value, bool isStart) {
    return Positioned(
      left: x - 6,
      top: 27,
      child: SizedBox(
        width: 12,
        height: 12,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: OvalBorder(side: BorderSide(width: 1, color: Color(0x1A000000))),
              ),
            ),
            Positioned(
              left: -7,
              top: -30,
              child: Container(
                width: 26,
                height: 24,
                decoration: BoxDecoration(color: const Color(0xFFFA4E02), borderRadius: BorderRadius.circular(4)),
                child: Center(
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSection() {
    return _buildSection(
      title: 'Пол',
      children: [
        _buildGenderRow(
          label: 'Мужчины',
          isSelected: _isMaleSelected,
          onTap: () => setState(() => _isMaleSelected = !_isMaleSelected),
        ),
        _buildDivider(),
        _buildGenderRow(
          label: 'Женщины',
          isSelected: _isFemaleSelected,
          onTap: () => setState(() => _isFemaleSelected = !_isFemaleSelected),
        ),
      ],
    );
  }

  Widget _buildGenderRow({required String label, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Inter'))),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFA4E02) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: isSelected ? const Color(0xFFFA4E02) : const Color(0xFFD1D1D6), width: 1.5),
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldSection({required String title, required TextEditingController controller}) {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12, fontFamily: 'Inter')),
          const SizedBox(height: 2),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
              style: const TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagSection({
    required String title,
    required List<String> selectedTags,
    required Color tagColor,
    required VoidCallback onAddTap,
    required Function(String) onDeleteTag,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12, fontFamily: 'Inter')),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Кнопка Добавить
              GestureDetector(
                onTap: onAddTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Color(0xFF007AFF), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Добавить',
                        style: TextStyle(
                          color: Color(0xFF007AFF),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Список тегов
              ...selectedTags.map((tag) => Container(
                    padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => onDeleteTag(tag),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSection() {
    return _buildSection(
      title: 'Период',
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('С', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCalendarOpen = !_isCalendarOpen),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: const Color(0xFFF7F6F2), borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.centerLeft,
                        child: Text(_formatDate(_startDate ?? DateTime(2025, 1, 1)), style: const TextStyle(color: Colors.black)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('До', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCalendarOpen = !_isCalendarOpen),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: const Color(0xFFF7F6F2), borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.centerLeft,
                        child: Text(_formatDate(_endDate ?? DateTime(2026, 1, 1)), style: const TextStyle(color: Colors.black)),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isCalendarOpen) ...[const SizedBox(height: 16), _buildModernCalendar()],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernCalendar() {
    final daysInMonth = _getDaysInMonth(_focusedDate);
    final offset = _getFirstWeekdayOffset(_focusedDate);
    final totalItems = daysInMonth + offset;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF2F2F7))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildDatePickerButton(_months[_focusedDate.month - 1], const Color(0xFFFA4E02), onTap: () => setState(() { _showMonthPicker = !_showMonthPicker; _showYearPicker = false; })),
                    const SizedBox(width: 8),
                    _buildDatePickerButton(_focusedDate.year.toString(), const Color(0xFFFA4E02), onTap: () => setState(() { _showYearPicker = !_showYearPicker; _showMonthPicker = false; })),
                  ],
                ),
                TextButton(onPressed: _resetDates, child: const Text('Сбросить', style: TextStyle(color: Color(0xFFFA4E02), fontSize: 13, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_showMonthPicker) _buildMonthPickerOverlay(),
          if (_showYearPicker) _buildYearPickerOverlay(),
          if (!_showMonthPicker && !_showYearPicker)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['П', 'В', 'С', 'Ч', 'П', 'С', 'В'].map((day) => Expanded(child: Text(day, textAlign: TextAlign.center, style: TextStyle(color: (day == 'С' || day == 'В') ? const Color(0xFF8E8E93) : Colors.black, fontSize: 10, fontWeight: FontWeight.w600)))).toList(),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8),
                    itemCount: totalItems,
                    itemBuilder: (context, index) {
                      if (index < offset) return const SizedBox.shrink();
                      final day = index - offset + 1;
                      final date = DateTime(_focusedDate.year, _focusedDate.month, day);
                      bool isStart = _startDate != null && date.year == _startDate!.year && date.month == _startDate!.month && date.day == _startDate!.day;
                      bool isEnd = _endDate != null && date.year == _endDate!.year && date.month == _endDate!.month && date.day == _endDate!.day;
                      bool isInRange = _startDate != null && _endDate != null && date.isAfter(_startDate!) && date.isBefore(_endDate!);
                      return GestureDetector(
                        onTap: () => _onDateTap(date),
                        child: Container(
                          decoration: BoxDecoration(color: (isStart || isEnd) ? const Color(0xFFFA4E02) : (isInRange ? const Color(0xFFFA4E02).withOpacity(0.1) : null), shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text('$day', style: TextStyle(color: (isStart || isEnd) ? Colors.white : Colors.black, fontSize: 14)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: () => setState(() => _isCalendarOpen = false), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFA4E02), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: const Text('Применить', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthPickerOverlay() {
    return Container(height: 200, child: GridView.builder(padding: const EdgeInsets.all(8), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.5), itemCount: 12, itemBuilder: (context, index) { final isSelected = _focusedDate.month == index + 1; return GestureDetector(onTap: () { setState(() { _focusedDate = DateTime(_focusedDate.year, index + 1); _showMonthPicker = false; }); }, child: Container(alignment: Alignment.center, margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: isSelected ? const Color(0xFFFA4E02).withOpacity(0.1) : null, borderRadius: BorderRadius.circular(8)), child: Text(_months[index], style: TextStyle(color: isSelected ? const Color(0xFFFA4E02) : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)))); }));
  }

  Widget _buildYearPickerOverlay() {
    final currentYear = DateTime.now().year;
    return Container(height: 200, child: ListView.builder(padding: const EdgeInsets.all(8), itemCount: 20, itemBuilder: (context, index) { final year = currentYear - 10 + index; final isSelected = _focusedDate.year == year; return ListTile(dense: true, title: Text(year.toString(), textAlign: TextAlign.center, style: TextStyle(color: isSelected ? const Color(0xFFFA4E02) : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)), onTap: () { setState(() { _focusedDate = DateTime(year, _focusedDate.month); _showYearPicker = false; }); }); }));
  }

  Widget _buildDatePickerButton(String label, Color color, {required VoidCallback onTap}) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(100)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500)), const SizedBox(width: 4), Icon(Icons.keyboard_arrow_down, size: 16, color: color)])));
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8), child: Text(title, style: const TextStyle(color: Colors.black, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w600))), ...children]));
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF2F2F7));
  }
}
