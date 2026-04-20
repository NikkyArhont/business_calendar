import 'package:flutter/material.dart';
import 'package:business_calendar/shared/widgets/app_primary_button.dart';
import 'package:business_calendar/config/constants/app_colors.dart';

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
  final TextEditingController _statusController = TextEditingController();

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
    // 0 = Monday, 6 = Sunday
    return DateTime(date.year, date.month, 1).weekday - 1;
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.75),
        elevation: 0,
        centerTitle: false, // Align left like the calendar
        title: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'Аналитика',
            style: TextStyle(
              color: Color(0xFF1C1B1F),
              fontSize: 22,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
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
            _buildStatusSection(title: 'Статус'),
            const SizedBox(height: 12),
            _buildPeriodSection(),
            const SizedBox(height: 12),
            _buildStatusSection(title: 'Откуда пришел, источник рекламы'),
            const SizedBox(height: 12),
            _buildStatusSection(title: 'Профессия'),
            const SizedBox(height: 12),
            _buildStatusSection(title: 'Регион'),
            const SizedBox(height: 12),
            _buildStatusSection(title: 'Боль клиента'),
            const SizedBox(height: 12),
            _buildStatusSection(title: 'Решение'),
            const SizedBox(height: 32),
            AppPrimaryButton(
              text: 'Показать аналитику',
              onPressed: () {
                // TODO: Navigate to analytics results screen
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
                  const SizedBox(height: 32), // Space for markers
                  Container(
                    width: width,
                    height: 58,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Ticks and Numbers
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: Container(
                            width: width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(11, (index) {
                                return Opacity(
                                  opacity: 0.20,
                                  child: Text(
                                    '${index * 10}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        // Track (Inactive)
                        Positioned(
                          left: 0,
                          top: 30.5,
                          child: Container(
                            width: width,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F6F2),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                        // Track (Active)
                        Positioned(
                          left: startX,
                          top: 30.5,
                          child: Container(
                            width: (endX - startX).clamp(0, width),
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFA4E02),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                        // Handles and Markers
                        _buildSliderHandle(startX, _ageRange.start.toInt().toString(), true),
                        _buildSliderHandle(endX, _ageRange.end.toInt().toString(), false),
                        
                        // Invisible Slider for interactions (keep using RangeSlider for logic if possible, or manual)
                        // For simplicity in this UI task, I'll overlay a transparent RangeSlider
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
                              rangeThumbShape: const RoundRangeSliderThumbShape(
                                enabledThumbRadius: 20,
                                elevation: 0,
                                pressedElevation: 0,
                              ),
                            ),
                            child: RangeSlider(
                              values: _ageRange,
                              min: 0,
                              max: 100,
                              divisions: 100,
                              onChanged: (values) {
                                setState(() {
                                  _ageRange = values;
                                });
                              },
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
      left: x - 6, // 12/2
      top: 27,
      child: SizedBox(
        width: 12,
        height: 12,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Handle
            Container(
              width: 12,
              height: 12,
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: OvalBorder(
                  side: BorderSide(
                    width: 1,
                    color: Color(0x1A000000),
                  ),
                ),
              ),
            ),
            // Marker (Bubble)
            Positioned(
              left: -7,
              top: -30,
              child: Container(
                width: 26,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFFA4E02),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
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
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFA4E02) : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFA4E02) : const Color(0xFFD1D1D6),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStatusSection({required String title}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.33,
            ),
          ),
          // Placeholder for future tags
          const SizedBox(height: 20),
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
                        decoration: BoxDecoration(
                          color: _startDate != null ? const Color(0x1F0088FF) : const Color(0xFFF7F6F2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatDate(_startDate),
                          style: TextStyle(
                            color: _startDate != null ? const Color(0xFF007AFF) : const Color(0xFF8E8E93),
                          ),
                        ),
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
                        decoration: BoxDecoration(
                          color: _endDate != null ? const Color(0x1F0088FF) : const Color(0xFFF7F6F2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatDate(_endDate),
                          style: TextStyle(
                            color: _endDate != null ? const Color(0xFF007AFF) : const Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isCalendarOpen) ...[
                const SizedBox(height: 16),
                _buildModernCalendar(),
              ],
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF2F2F7)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildDatePickerButton(
                      _months[_focusedDate.month - 1],
                      const Color(0xFFFA4E02),
                      onTap: () => setState(() {
                        _showMonthPicker = !_showMonthPicker;
                        _showYearPicker = false;
                      }),
                    ),
                    const SizedBox(width: 8),
                    _buildDatePickerButton(
                      _focusedDate.year.toString(),
                      const Color(0xFFFA4E02),
                      onTap: () => setState(() {
                        _showYearPicker = !_showYearPicker;
                        _showMonthPicker = false;
                      }),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _resetDates,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Сбросить',
                    style: TextStyle(
                      color: Color(0xFFFA4E02),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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
                    children: ['П', 'В', 'С', 'Ч', 'П', 'С', 'В'].map((day) {
                      final isWeekend = day == 'С' || day == 'В'; // Simplified check
                      return Expanded(
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isWeekend ? const Color(0xFF8E8E93) : Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: totalItems,
                    itemBuilder: (context, index) {
                      if (index < offset) return const SizedBox.shrink();

                      final day = index - offset + 1;
                      final date = DateTime(_focusedDate.year, _focusedDate.month, day);
                      
                      bool isStart = _startDate != null && 
                          date.year == _startDate!.year && 
                          date.month == _startDate!.month && 
                          date.day == _startDate!.day;
                          
                      bool isEnd = _endDate != null && 
                          date.year == _endDate!.year && 
                          date.month == _endDate!.month && 
                          date.day == _endDate!.day;

                      bool isInRange = _startDate != null && _endDate != null &&
                          date.isAfter(_startDate!) && date.isBefore(_endDate!);
                      
                      return GestureDetector(
                        onTap: () => _onDateTap(date),
                        child: Container(
                          decoration: BoxDecoration(
                            color: (isStart || isEnd) 
                                ? const Color(0xFFFA4E02) 
                                : (isInRange ? const Color(0xFFFA4E02).withOpacity(0.1) : null),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: (isStart || isEnd) ? Colors.white : Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isCalendarOpen = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFA4E02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Применить',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthPickerOverlay() {
    return Container(
      height: 200,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.5,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final isSelected = _focusedDate.month == index + 1;
          return GestureDetector(
            onTap: () {
              setState(() {
                _focusedDate = DateTime(_focusedDate.year, index + 1);
                _showMonthPicker = false;
              });
            },
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFA4E02).withOpacity(0.1) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _months[index],
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFA4E02) : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildYearPickerOverlay() {
    final currentYear = DateTime.now().year;
    return Container(
      height: 200,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: 20,
        itemBuilder: (context, index) {
          final year = currentYear - 10 + index;
          final isSelected = _focusedDate.year == year;
          return ListTile(
            dense: true,
            title: Text(
              year.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFA4E02) : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () {
              setState(() {
                _focusedDate = DateTime(year, _focusedDate.month);
                _showYearPicker = false;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildDatePickerButton(String label, Color color, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF2F2F7));
  }
}
