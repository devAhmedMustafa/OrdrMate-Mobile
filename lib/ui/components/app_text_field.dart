import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? prefix;
  final Widget? suffix;
  final int? maxLines;
  final int? minLines;
  final bool enabled;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      style: const TextStyle(color: AppTheme.textPrimaryColor),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: true,
        fillColor: AppTheme.surfaceColor,
        labelStyle: const TextStyle(color: AppTheme.textSecondaryColor),
        hintStyle: const TextStyle(color: AppTheme.textSecondaryColor),
        errorStyle: const TextStyle(color: AppTheme.errorColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
        contentPadding: const EdgeInsets.all(AppTheme.spacingM),
      ),
    );
  }
} 