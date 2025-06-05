import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool elevated;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevated ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppTheme.spacingM),
          child: child,
        ),
      ),
    );
  }
} 