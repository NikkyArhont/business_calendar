import 'package:flutter/material.dart';
import 'package:business_calendar/config/constants/app_colors.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool _isMonthView = true;
  bool _isMonthPickerVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя панель с месяцем
            _buildTopAppBar(),
            
            // Выбор месяца/года (появляется по клику на заголовок)
            if (_isMonthPickerVisible) _buildMonthYearPicker(),
            
            // Заголовок календаря (Сетка дней недели)
            _buildWeekdaysHeader(),
            
            Expanded(
              child: Stack(
                children: [
                  // Сетка календаря
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: _isMonthView ? _buildCalendarGrid() : _buildWeekPlaceholder(),
                    ),
                  ),
                  
                  // Нижняя карточка дня
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: _buildDayDetailCard(),
                  ),
                ],
              ),
            ),
          ],
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
          // Месяц и Год (На кликабельной области)
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
                    const Text(
                      'Февраль, 2026',
                      style: TextStyle(
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
          
          // Правая кнопка (Переключатель вида)
          Padding(
            padding: const EdgeInsets.all(4),
            child: Builder(
              builder: (context) => IconButton(
                onPressed: () => _showViewMenu(context),
                icon: _buildViewToggleIcon(isMonthView: _isMonthView),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthYearPicker() {
    final months = ['Янв', 'Фев', 'Март', 'Апр', 'Май', 'Июнь', 'Июль', 'Авг', 'Сент', 'Окт', 'Ноя', 'Дек'];
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
            // Год
            _buildPickerChip('2026', isYear: true),
            const SizedBox(width: 8),
            // Месяцы
            ...months.map((month) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildPickerChip(month, isActive: month == 'Фев'),
            )),
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
        color: isYear ? Colors.transparent : const Color(0x0FFA4E02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isYear ? Colors.black : const Color(0xFFFA4E02),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: isYear ? FontWeight.w600 : FontWeight.w500,
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
            // Иконка вида слева
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
                  height: 1.29,
                  letterSpacing: -0.43,
                ),
              ),
            ),
            // Галка выбора справа (опционально, но помогает понять что выбрано)
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

  Widget _buildWeekPlaceholder() {
    return const Center(
      child: Text(
        'Вид: Неделя\n(В разработке)',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 16),
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
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 90,
      ),
      itemCount: 35,
      itemBuilder: (context, index) {
        int dayNumber;
        bool isNextMonth = false;
        bool isCurrentMonth = true;
        bool isSelected = false;

        if (index < 6) {
          dayNumber = 26 + index;
          isCurrentMonth = false;
        } else if (index == 6) {
          dayNumber = 1;
        } else {
          dayNumber = index - 5;
          if (dayNumber > 31) {
            dayNumber -= 31;
            isNextMonth = true;
          }
        }

        if (dayNumber == 21 && !isNextMonth && isCurrentMonth) {
          isSelected = true;
        }

        return _buildCalendarCell(dayNumber, isCurrentMonth, isSelected, index);
      },
    );
  }

  Widget _buildCalendarCell(int day, bool isCurrentMonth, bool isSelected, int index) {
    final Color textColor = isSelected 
        ? Colors.white 
        : (isCurrentMonth ? Colors.black : const Color(0x2D3C3C43));

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFC7C7CC), width: 0.33),
          right: BorderSide(color: Color(0xFFC7C7CC), width: 0.33),
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
                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w400),
                  ),
            ),
          ),
          
          if (day == 10 && isCurrentMonth) ...[
            Positioned(
              left: 2,
              right: 2,
              top: 34,
              child: _buildEventChip('Имя контакта', const Color(0xFF0088FF)),
            ),
            Positioned(
              left: 2,
              right: 2,
              top: 58,
              child: _buildEventChip('Название со...', const Color(0xFF6155F5)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        border: Border.all(color: color, width: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDayDetailCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '21, Суббота',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x0FFA4E02),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '0 событий',
              style: TextStyle(
                color: Color(0xFFFA4E02),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
