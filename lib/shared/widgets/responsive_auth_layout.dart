import 'package:flutter/material.dart';
import 'package:business_calendar/config/constants/app_colors.dart';

class ResponsiveAuthLayout extends StatelessWidget {
  final Widget child;
  final bool showBackButton;

  const ResponsiveAuthLayout({
    super.key, 
    required this.child,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final backButton = Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(top: 16, left: 16),
      decoration: BoxDecoration(
        color: AppColors.buttonPrimary, // Оранжевый цвет
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Web / Desktop Layout (Split Screen)
          return Row(
            children: [
              // Левая часть: Градиент и Логотип
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF79433), // Оранжевый градиент из макета
                        Color(0xFFE5692A),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 250, // Размер логотипа можно скорректировать
                    ),
                  ),
                ),
              ),
              // Правая часть: Форма
              Expanded(
                child: Container(
                  color: AppColors.splashBackground, // Цвет фона формы
                  child: Stack(
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: child,
                        ),
                      ),
                      if (showBackButton)
                        Positioned(
                          top: 24,
                          left: 24,
                          child: backButton,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        // Mobile Layout (Оригинальное отображение)
        return Stack(
          children: [
            child,
            if (showBackButton)
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: backButton,
                ),
              ),
          ],
        );
      },
    );
  }
}
