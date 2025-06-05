import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;
  final bool isLoading;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? AppTheme.surfaceColor : AppTheme.primaryColor,
        foregroundColor: isSecondary ? AppTheme.textPrimaryColor : Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingL,
          vertical: AppTheme.spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else ...[
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: AppTheme.spacingS),
            ],
            Text(text),
          ],
        ],
      ),
    );
  }
} 