import 'package:flutter/material.dart';

class AppAlertDialog extends StatelessWidget {
  final String title;
  final String actionTitle;
  final VoidCallback onAction;
  final bool isDestructive;

  const AppAlertDialog({
    super.key,
    required this.title,
    required this.actionTitle,
    required this.onAction,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 270,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFF383838),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Текст сообщения
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 19, 16, 15),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                    height: 1.29,
                    letterSpacing: -0.40,
                  ),
                ),
              ),
              // Разделитель горизонтальный
              const Divider(height: 0.33, color: Color(0x5B3C3C43)),
              // Кнопки
              IntrinsicHeight(
                child: Row(
                  children: [
                    // Кнопка Отмена
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          child: const Text(
                            'Отмена',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF007AFF),
                              fontSize: 17,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Разделитель вертикальный
                    const VerticalDivider(width: 0.33, color: Color(0x5B3C3C43)),
                    // Кнопка действия
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          onAction();
                        },
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          child: Text(
                            actionTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDestructive ? const Color(0xFFFF383C) : const Color(0xFF007AFF),
                              fontSize: 17,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
