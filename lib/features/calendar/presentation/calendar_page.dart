import 'package:flutter/material.dart';
import 'package:business_calendar/config/constants/app_colors.dart';
import 'package:business_calendar/config/constants/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:business_calendar/core/services/firestore_service.dart';
import 'package:business_calendar/core/models/calendar_event.dart';
import 'package:business_calendar/features/calendar/presentation/event_detail_page.dart';
import 'package:business_calendar/features/calendar/presentation/add_event_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _isMonthView = true;
  // Removed old _isMonthPickerVisible
  bool _isSearchActive = false;
  CalendarEvent? _viewingEvent;
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

  void _handleCalendarSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    setState(() {
      if (details.primaryVelocity! < 0) {
        // Swipe left -> Next
        if (_isMonthView) {
          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
        } else {
          _selectedDay = _selectedDay.add(const Duration(days: 7));
          _focusedDay = _selectedDay;
        }
      } else if (details.primaryVelocity! > 0) {
        // Swipe right -> Previous
        if (_isMonthView) {
          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
        } else {
          _selectedDay = _selectedDay.subtract(const Duration(days: 7));
          _focusedDay = _selectedDay;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth > 800;

        return Scaffold(
          backgroundColor: isWeb ? Colors.white : AppColors.splashBackground,
          body: SafeArea(
            child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
          ),
          floatingActionButton: isWeb ? null : FloatingActionButton(
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
      },
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Верхняя панель с месяцем
        _buildTopAppBar(),
        
        // Выбор месяца/года
        // Выбор месяца/года (удален старый вариант)
        
        // Заголовок календаря (Сетка дней недели)
        _buildWeekdaysHeader(),
        
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Сетка календаря
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) => _handleCalendarSwipe(details),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _isMonthView 
                        ? _buildCalendarGrid() 
                        : _buildWeekView(),
                    ),
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
    );
  }

  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Левая часть (календарь)
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildTopAppBar(isWeb: true),
              _isMonthView ? _buildWeekdaysHeader() : const SizedBox(),
              Expanded(
                child: _isMonthView
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GestureDetector(
                            onHorizontalDragEnd: (details) => _handleCalendarSwipe(details),
                            child: _buildCalendarGrid(isWeb: true),
                          ),
                        ),
                      )
                    : _buildWebWeekView(),
              ),
            ],
          ),
        ),
        
        // Вертикальный разделитель
        Container(
          width: 1,
          color: const Color(0xFFDADCE0),
        ),

        // Правая часть (События на выбранный день)
        Expanded(
          flex: 3,
          child: Container(
            color: const Color(0xFFF7F6F2), // Светлый фон как в макете
            height: double.infinity,
            child: _viewingEvent != null
                ? EventDetailPage(
                    event: _viewingEvent!,
                    isEmbedded: true,
                    onBack: () {
                      setState(() {
                        _viewingEvent = null;
                      });
                    },
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDayDetailCard(isWeb: true),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebWeekView() {
    final DateTime startOfWeek = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
    final hours = List.generate(12, (i) => i + 8); // 08:00 to 19:00
    final double hourHeight = 60.0;
    
    return Column(
      children: [
        // Week days header
        Padding(
          padding: const EdgeInsets.only(left: 60.0, right: 16.0),
          child: Row(
            children: List.generate(7, (index) {
              final day = startOfWeek.add(Duration(days: index));
              final isSelected = day.day == _selectedDay.day && day.month == _selectedDay.month;
              final dayName = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'][index];
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = day;
                      _focusedDay = day;
                      _viewingEvent = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE5E5E5)),
                        right: BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                    ),
                    child: Center(
                      child: isSelected
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$dayName ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(color: Color(0xFFDE642E), shape: BoxShape.circle),
                                child: Text('${day.day}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ],
                          )
                        : Text('$dayName, ${day.day}', style: const TextStyle(color: Colors.black, fontSize: 13)),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        // Timetable
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hours column
                  SizedBox(
                    width: 60,
                    child: Column(
                      children: hours.map((hour) => Container(
                        height: hourHeight,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 8, top: 4),
                        child: Text('${hour.toString().padLeft(2, '0')}:00', style: const TextStyle(color: Color(0xFF333333), fontSize: 11)),
                      )).toList(),
                    ),
                  ),
                  // Grid
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double dayWidth = constraints.maxWidth / 7;
                        
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Background grid
                            Column(
                              children: hours.map((hour) => Container(
                                height: hourHeight,
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
                                ),
                                child: Row(
                                  children: List.generate(7, (index) => Expanded(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(right: BorderSide(color: Color(0xFFE5E5E5))),
                                      ),
                                    ),
                                  )),
                                ),
                              )).toList(),
                            ),
                            
                            // Events
                            ..._events.map((event) {
                              final eventDate = event.startTime;
                              final daysDifference = eventDate.difference(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)).inDays;
                              
                              if (daysDifference >= 0 && daysDifference < 7 && eventDate.hour >= 8 && eventDate.hour <= 19) {
                                final left = daysDifference * dayWidth;
                                final top = (eventDate.hour - 8) * hourHeight + (eventDate.minute / 60) * hourHeight;
                                
                                final durationInMinutes = event.endTime.difference(event.startTime).inMinutes;
                                final height = (durationInMinutes / 60) * hourHeight;
                                
                                final isContactEvent = event.selectedContacts.isNotEmpty;
                                final startTimeStr = DateFormat('HH:mm').format(event.startTime);
                                final endTimeStr = DateFormat('HH:mm').format(event.endTime);
                                
                                return Positioned(
                                  left: left + 2,
                                  top: top,
                                  width: dayWidth - 4,
                                  height: height < 20 ? 20 : height,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDay = event.startTime;
                                        _viewingEvent = event;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: isContactEvent ? const Color(0x1A0088FF) : const Color(0x1A6155F5),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border(
                                          left: BorderSide(
                                            color: isContactEvent ? const Color(0xFF0088FF) : const Color(0xFF6155F5),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  isContactEvent ? (event.selectedContacts.first['name'] ?? 'Контакт') : event.title,
                                                  style: TextStyle(
                                                    color: isContactEvent ? const Color(0xFF0088FF) : const Color(0xFF6155F5),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (height > 30)
                                                  Text(
                                                    event.title,
                                                    style: TextStyle(
                                                      color: isContactEvent ? const Color(0xFF0088FF) : const Color(0xFF6155F5),
                                                      fontSize: 9,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (height > 40)
                                            Text(
                                              '$startTimeStr -\n$endTimeStr',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                color: isContactEvent ? const Color(0xFF0088FF) : const Color(0xFF6155F5),
                                                fontSize: 9,
                                              ),
                                            )
                                          else
                                            Text(
                                              startTimeStr,
                                              style: TextStyle(
                                                color: isContactEvent ? const Color(0xFF0088FF) : const Color(0xFF6155F5),
                                                fontSize: 9,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopAppBar({bool isWeb = false}) {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Builder(
              builder: (context) => GestureDetector(
                onTap: () {
                  _showViewMenu(context);
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
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF1C1B1F),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          if (isWeb)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSearchActive)
                  SizedBox(
                    width: 250,
                    height: 35,
                    child: Autocomplete<CalendarEvent>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<CalendarEvent>.empty();
                        }
                        return _events.where((CalendarEvent event) {
                          return event.title.toLowerCase().contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      displayStringForOption: (CalendarEvent option) => option.title,
                      onSelected: (CalendarEvent selection) {
                        setState(() {
                          _selectedDay = selection.startTime;
                          _focusedDay = selection.startTime;
                          _isSearchActive = false;
                          _viewingEvent = selection;
                        });
                      },
                      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Запрос',
                            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF1C1B1F)),
                            suffixIcon: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.search, color: Color(0xFFDE642E), size: 20),
                              onPressed: () {
                                setState(() => _isSearchActive = false);
                              },
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF7F6F2),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(fontSize: 14, color: Color(0xFF1C1B1F)),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Color(0xFFE5E5EA)),
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 250, maxWidth: 250),
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final CalendarEvent option = options.elementAt(index);
                                  return InkWell(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                      child: Text(
                                        option.title,
                                        style: const TextStyle(fontSize: 14, color: Color(0xFF1C1B1F)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      setState(() => _isSearchActive = true);
                    },
                    child: Container(
                      height: 35,
                      width: 35,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF7F6F2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Icon(Icons.search, color: Color(0xFFDE642E), size: 20),
                    ),
                  ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: const SizedBox(
                          width: 600,
                          height: 800,
                          child: AddEventPage(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFA4E02),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Добавить событие',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.add_circle, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          if (!isWeb)
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
    
    final offset = button.localToGlobal(Offset.zero, ancestor: overlay);
    
    double topPosition = offset.dy + button.size.height + 8;
    double leftPosition = offset.dx;
    
    // Prevent overflow on right
    if (leftPosition + 320 > overlay.size.width) {
      leftPosition = overlay.size.width - 320 - 16;
    }
    // Prevent overflow on left
    if (leftPosition < 16) {
      leftPosition = 16;
    }

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned(
            top: topPosition,
            left: leftPosition,
            child: Material(
              color: Colors.transparent,
              child: CalendarViewMenu(
                initialIsMonthView: _isMonthView,
                initialFocusedDay: _focusedDay,
                initialSelectedDay: _selectedDay,
                onChanged: (isMonthView, focusedDay) {
                  setState(() {
                    _isMonthView = isMonthView;
                    _focusedDay = focusedDay;
                    _selectedDay = focusedDay;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Removed old _buildCustomMenu

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
          // Числа недели
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final day = startOfWeek.add(Duration(days: index));
              final isSelected = day.day == _selectedDay.day && 
                                day.month == _selectedDay.month && 
                                day.year == _selectedDay.year;

              final dayEvents = _events.where((e) => 
                e.startTime.year == day.year && 
                e.startTime.month == day.month && 
                e.startTime.day == day.day
              ).toList();

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = day;
                      _viewingEvent = null;
                    });
                  },
                  child: Container(
                    height: 70, // Увеличили для вмещения линий событий
                    alignment: Alignment.topCenter,
                    color: Colors.transparent, // Для корректной работы tap
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isSelected 
                          ? Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.only(top: 4, bottom: 4),
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
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
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
                        if (dayEvents.isNotEmpty)
                          _buildWeekEventLines(dayEvents),
                      ],
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

  Widget _buildWeekEventLines(List<CalendarEvent> dayEvents) {
    return SizedBox(
      height: 20,
      width: 40,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: dayEvents.take(3).map((event) {
              final color = Color(event.colorValue);

              return Container(
                width: 28,
                height: 3,
                margin: const EdgeInsets.only(bottom: 3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            }).toList(),
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

  Widget _buildCalendarGrid({bool isWeb = false}) {
    final int daysInMonth = _daysInMonth(_focusedDay);
    final int offset = _firstDayOffset(_focusedDay);
    final DateTime prevMonth = DateTime(_focusedDay.year, _focusedDay.month - 1);
    final int daysInPrevMonth = _daysInMonth(prevMonth);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: isWeb ? 150 : 110,
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
                _viewingEvent = null;
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
                final eventColor = Color(event.colorValue);
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: ShapeDecoration(
                    color: eventColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: eventColor,
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
                      color: eventColor,
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

  Widget _buildDayDetailCard({bool isWeb = false}) {
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

              ...dayEvents.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                return Column(
                  children: [
                    if (index > 0) const _DottedDivider(),
                    _buildEventItem(event, isWeb: isWeb),
                  ],
                );
              }),
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

  Widget _buildEventItem(CalendarEvent event, {bool isWeb = false}) {
    final isContactEvent = event.selectedContacts.isNotEmpty;
    final color = Color(event.colorValue);
    final timeRange = event.isAllDay ? 'весь день' : '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}';
    
    return GestureDetector(
      onTap: () {
        if (isWeb) {
          setState(() {
            _viewingEvent = event;
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailPage(event: event),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Vertical bar
            Container(
              width: 3,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isContactEvent 
                      ? (event.selectedContacts.map((c) => c['name']).join(', '))
                      : event.title,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isContactEvent ? event.title : (event.type ?? 'Без категории'),
                    style: const TextStyle(
                      color: Color(0x993C3C43),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomPaint(
        size: const Size(double.infinity, 1),
        painter: _DottedLinePainter(),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0088FF).withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 2.0;
    const dashSpace = 2.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CalendarViewMenu extends StatefulWidget {
  final bool initialIsMonthView;
  final DateTime initialFocusedDay;
  final DateTime initialSelectedDay;
  final Function(bool isMonthView, DateTime focusedDay) onChanged;

  const CalendarViewMenu({
    super.key,
    required this.initialIsMonthView,
    required this.initialFocusedDay,
    required this.initialSelectedDay,
    required this.onChanged,
  });

  @override
  State<CalendarViewMenu> createState() => _CalendarViewMenuState();
}

class _CalendarViewMenuState extends State<CalendarViewMenu> {
  late bool _isMonthView;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _isMonthView = widget.initialIsMonthView;
    _focusedDay = DateTime(widget.initialFocusedDay.year, widget.initialFocusedDay.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  int get _daysInMonth => DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
  int get _firstDayOffset => (_focusedDay.weekday - 1) % 7;

  @override
  Widget build(BuildContext context) {
    final months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    final weekDays = ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];

    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadows: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 32,
            offset: Offset(0, 0),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Segmented Control
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F6F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _isMonthView = false);
                      widget.onChanged(_isMonthView, _focusedDay);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: !_isMonthView ? const Color(0xFFDE642E) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Неделя',
                        style: TextStyle(
                          color: !_isMonthView ? Colors.white : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _isMonthView = true);
                      widget.onChanged(_isMonthView, _focusedDay);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isMonthView ? const Color(0xFFDE642E) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Месяц',
                        style: TextStyle(
                          color: _isMonthView ? Colors.white : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Month/Year header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF333333)),
                onPressed: _previousMonth,
              ),
              Text(
                '${months[_focusedDay.month - 1]}, ${_focusedDay.year}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, size: 20, color: Color(0xFF333333)),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Weekdays header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((d) => SizedBox(
              width: 32,
              child: Text(
                d,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF999999), fontSize: 12),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - _firstDayOffset + 1;
              final isCurrentMonth = dayNumber > 0 && dayNumber <= _daysInMonth;
              
              DateTime cellDate;
              if (isCurrentMonth) {
                cellDate = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
              } else if (dayNumber <= 0) {
                cellDate = DateTime(_focusedDay.year, _focusedDay.month, 0).subtract(Duration(days: -dayNumber));
              } else {
                cellDate = DateTime(_focusedDay.year, _focusedDay.month + 1, dayNumber - _daysInMonth);
              }

              final isSelected = cellDate.year == widget.initialSelectedDay.year &&
                                 cellDate.month == widget.initialSelectedDay.month &&
                                 cellDate.day == widget.initialSelectedDay.day;

              return GestureDetector(
                onTap: () {
                  widget.onChanged(_isMonthView, cellDate);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFDE642E) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${cellDate.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isCurrentMonth ? Colors.black : const Color(0xFFCCCCCC)),
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
