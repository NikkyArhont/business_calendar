import 'package:flutter/material.dart';
import 'package:business_calendar/config/constants/app_colors.dart';

class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? prefixIcon;
  final BorderSide? border;

  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.prefixIcon,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: backgroundColor ?? AppColors.buttonPrimary,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        shape: border != null
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: border!,
              )
            : null,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (prefixIcon != null) ...[
                          prefixIcon!,
                          const SizedBox(width: 10),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: textColor ?? Colors.white,
                            fontSize: 16, // User snippet used 16 for social buttons
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
