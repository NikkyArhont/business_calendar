import 'package:flutter/material.dart';
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/config/constants/app_routes.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _isMonthView = true;
  bool _isMonthPickerVisible = false;

  final List<String> _months = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
  ];

  // Получение количества дней в месяце
  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  // Получение дня недели первого дня месяца (0 - Пн, 6 - Вс)
  int _firstDayOffset(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    return firstDay.weekday - 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя панель с месяцем
            _buildTopAppBar(),
            
            // Выбор месяца/года
            if (_isMonthPickerVisible) _buildMonthYearPicker(),
            
            // Заголовок календаря (Сетка дней недели)
            _buildWeekdaysHeader(),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Сетка календаря
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: _isMonthView ? 380 : 140, // Динамическая высота
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: _isMonthView ? _buildCalendarGrid() : _buildWeekView(),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Детали дня под календарем
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildDayDetailCard(),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addEvent);
        },
        backgroundColor: const Color(0xFFFA4E02),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isMonthPickerVisible = !_isMonthPickerVisible;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Text(
                      '${_months[_focusedDay.month - 1]}, ${_focusedDay.year}',
                      style: const TextStyle(
                        color: Color(0xFF1C1B1F),
                        fontSize: 22,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isMonthPickerVisible ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: const Color(0xFF1C1B1F),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Builder(
            builder: (context) => IconButton(
              onPressed: () => _showViewMenu(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: _buildViewToggleIcon(isMonthView: _isMonthView),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthYearPicker() {
    final shortMonths = ['Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн', 'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек'];
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _focusedDay = DateTime(_focusedDay.year + 1, _focusedDay.month);
                });
              },
              child: _buildPickerChip('${_focusedDay.year}', isYear: true),
            ),
            const SizedBox(width: 8),
            ...List.generate(12, (index) {
              final monthName = shortMonths[index];
              final isSelected = _focusedDay.month == index + 1;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, index + 1);
                    });
                  },
                  child: _buildPickerChip(monthName, isActive: isSelected),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerChip(String text, {bool isYear = false, bool isActive = false}) {
    return Container(
      height: 32,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: isYear ? Colors.transparent : (isActive ? AppColors.logoGradientEnd.withOpacity(0.1) : const Color(0x0FFA4E02)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isActive ? const BorderSide(color: AppColors.logoGradientEnd, width: 1) : BorderSide.none,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isYear ? Colors.black : (isActive ? AppColors.logoGradientEnd : const Color(0xFFFA4E02)),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: (isYear || isActive) ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _showViewMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, button.size.height), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned(
            top: position.top + 8,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: _buildCustomMenu(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomMenu() {
    return Container(
      width: 250,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 32,
            offset: Offset(0, 0),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuItem(
            'Месяц', 
            icon: _buildViewToggleIcon(isMonthView: true),
            isActive: _isMonthView, 
            onTap: () {
              setState(() => _isMonthView = true);
              Navigator.pop(context);
            },
          ),
          const Divider(height: 0.5, color: Color(0x8C808080)),
          _buildMenuItem(
            'Неделя', 
            icon: _buildViewToggleIcon(isMonthView: false),
            isActive: !_isMonthView, 
            onTap: () {
              setState(() => _isMonthView = false);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, {required Widget icon, required bool isActive, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Center(child: icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (isActive)
              const Icon(Icons.check, size: 20, color: AppColors.logoGradientEnd),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggleIcon({required bool isMonthView}) {
    if (isMonthView) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _square(),
              const SizedBox(width: 2),
              _square(),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _square(),
              const SizedBox(width: 2),
              _square(),
            ],
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _rectangle(),
          const SizedBox(width: 2),
          _rectangle(),
        ],
      );
    }
  }

  Widget _square() => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: const Color(0xFFFA4E02),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _rectangle() => Container(
        width: 8,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFFFA4E02),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildWeekView() {
    // Вычисляем начало недели (Понедельник) для выбранного дня
    final DateTime startOfWeek = _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Заголовки дней недели (П, В, С...)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['П', 'В', 'С', 'Ч', 'П', 'С', 'В'].map((day) => Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0x993C3C43),
                    fontSize: 10,
                    fontFamily: 'Inter', // Используем Inter для единообразия
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Числа недели
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final day = startOfWeek.add(Duration(days: index));
              final isSelected = day.day == _selectedDay.day && 
                                day.month == _selectedDay.month && 
                                day.year == _selectedDay.year;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = day;
                      _focusedDay = day;
                    });
                  },
                  child: Container(
                    height: 60, // Сделал чуть компактнее чем в макете для баланса
                    alignment: Alignment.topCenter,
                    child: isSelected 
                      ? Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFA4E02),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${day.day}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdaysHeader() {
    final days = ['П', 'В', 'С', 'Ч', 'П', 'С', 'В'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((day) => Expanded(
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0x993C3C43),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final int daysInMonth = _daysInMonth(_focusedDay);
    final int offset = _firstDayOffset(_focusedDay);
    final DateTime prevMonth = DateTime(_focusedDay.year, _focusedDay.month - 1);
    final int daysInPrevMonth = _daysInMonth(prevMonth);

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 58,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        int dayNumber;
        bool isCurrentMonth = true;
        
        if (index < offset) {
          dayNumber = daysInPrevMonth - offset + index + 1;
          isCurrentMonth = false;
        } else if (index >= offset + daysInMonth) {
          dayNumber = index - (offset + daysInMonth) + 1;
          isCurrentMonth = false;
        } else {
          dayNumber = index - offset + 1;
        }

        final bool isSelected = isCurrentMonth && 
            _selectedDay.day == dayNumber && 
            _selectedDay.month == _focusedDay.month &&
            _selectedDay.year == _focusedDay.year;

        final bool isToday = isCurrentMonth &&
            DateTime.now().day == dayNumber &&
            DateTime.now().month == _focusedDay.month &&
            DateTime.now().year == _focusedDay.year;

        return GestureDetector(
          onTap: () {
            if (isCurrentMonth) {
              setState(() {
                _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
              });
            }
          },
          child: _buildCalendarCell(dayNumber, isCurrentMonth, isSelected, isToday, index),
        );
      },
    );
  }

  Widget _buildCalendarCell(int day, bool isCurrentMonth, bool isSelected, bool isToday, int index) {
    final Color textColor = isSelected 
        ? Colors.white 
        : (isCurrentMonth 
            ? (isToday ? AppColors.logoGradientEnd : Colors.black) 
            : const Color(0x2D3C3C43));

    // Определяем, нужно ли рисовать нижнюю границу (не рисуем для последнего ряда, т.е. индексы 35-41)
    final bool showBottomBorder = index < 35;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: showBottomBorder 
              ? const BorderSide(color: Color(0xFFC7C7CC), width: 0.33) 
              : BorderSide.none,
          // Удалили right border (вертикальные линии)
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: isSelected 
                ? Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.logoGradientEnd,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w400),
                      ),
                    ),
                  )
                : Text(
                    '$day',
                    style: TextStyle(
                      color: textColor, 
                      fontSize: 18, 
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDetailCard() {
    final weekDays = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    final weekDayName = weekDays[_selectedDay.weekday - 1];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            shadows: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_selectedDay.day}, $weekDayName',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 1.50,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16), // Замена spacing
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: ShapeDecoration(
                          color: const Color(0x0FFA4E02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '0 событий',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFA4E02),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600, // Сделал 600 для четкости
                            height: 1.33,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
