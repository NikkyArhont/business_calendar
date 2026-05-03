import 'package:flutter/material.dart';
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/config/constants/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:business_calendar/core/services/firestore_service.dart';
import 'package:business_calendar/core/models/calendar_event.dart';
import 'package:business_calendar/features/calendar/presentation/event_detail_page.dart';

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
  final _firestoreService = FirestoreService();
  List<CalendarEvent> _events = [];

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
  void initState() {
    super.initState();
    _listenToEvents();
  }

  void _listenToEvents() {
    _firestoreService.getEvents().listen((events) {
      if (mounted) {
        setState(() {
          _events = events;
        });
      }
    });
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
                        child: _isMonthView 
                          ? _buildCalendarGrid() 
                          : _buildWeekView(),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 110,
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
    final DateTime cellDate = isCurrentMonth 
        ? DateTime(_focusedDay.year, _focusedDay.month, day)
        : (index < 7 // Simple logic for neighbor months
            ? DateTime(_focusedDay.year, _focusedDay.month - 1, day)
            : DateTime(_focusedDay.year, _focusedDay.month + 1, day));

    final dayEvents = _events.where((e) => 
      e.startTime.year == cellDate.year && 
      e.startTime.month == cellDate.month && 
      e.startTime.day == cellDate.day
    ).toList();

    final Color textColor = isSelected 
        ? Colors.white 
        : (isCurrentMonth 
            ? (isToday ? const Color(0xFFFA4E02) : Colors.black) 
            : const Color(0x2D3C3C43));

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: const BorderSide(color: Color(0xFFC7C7CC), width: 0.33),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Число
          Positioned(
            left: 0,
            right: 0,
            top: 8,
            child: isSelected 
              ? Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFA4E02),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                )
              : Text(
                  '$day',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor, 
                    fontSize: 18, 
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
          ),
          
          // События
          Positioned(
            left: 2,
            right: 2,
            top: 44,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: dayEvents.take(2).map((event) {
                final isContactEvent = event.selectedContacts.isNotEmpty;
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: ShapeDecoration(
                    color: isContactEvent ? const Color(0x0F0088FF) : const Color(0x0F6155F5),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: isContactEvent ? const Color(0xFF0088FF) : const Color(0xFF6155F5),
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  child: Text(
                    isContactEvent 
                      ? (event.selectedContacts.first['name'] ?? 'Контакт')
                      : event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isContactEvent ? const Color(0xFF0088FF) : const Color(0xFF6155F5),
                      fontSize: 8,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.03,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDetailCard() {
    final weekDays = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    final weekDayName = weekDays[_selectedDay.weekday - 1];
    
    final dayEvents = _events.where((e) => 
      e.startTime.year == _selectedDay.year && 
      e.startTime.month == _selectedDay.month && 
      e.startTime.day == _selectedDay.day
    ).toList();

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
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_selectedDay.day}, $weekDayName',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: ShapeDecoration(
                        color: const Color(0x0FFA4E02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '${dayEvents.length} ${_getEventWord(dayEvents.length)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFA4E02),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.33,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              if (dayEvents.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Событий нет',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

              // Events List
              ...dayEvents.map((event) => _buildEventItem(event)),
            ],
          ),
        ),
      ],
    );
  }

  String _getEventWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'событие';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) return 'события';
    return 'событий';
  }

  Widget _buildEventItem(CalendarEvent event) {
    final isContactEvent = event.selectedContacts.isNotEmpty;
    final color = isContactEvent ? const Color(0xFF0088FF) : const Color(0xFF6155F5);
    final timeRange = '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(event: event),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.transparent, // Make it tappable everywhere
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.38,
                      letterSpacing: -0.43,
                    ),
                  ),
                  Text(
                    isContactEvent 
                      ? (event.selectedContacts.map((c) => c['name']).join(', '))
                      : (event.type ?? 'Без категории'),
                    style: const TextStyle(
                      color: Color(0x993C3C43),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      letterSpacing: -0.23,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timeRange,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.69,
                letterSpacing: -0.43,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
