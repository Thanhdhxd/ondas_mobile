import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_radius.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';

class AuthTextFieldWidget extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Key? fieldKey;

  const AuthTextFieldWidget({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.fieldKey,
  });

  @override
  State<AuthTextFieldWidget> createState() => _AuthTextFieldWidgetState();
}

class _AuthTextFieldWidgetState extends State<AuthTextFieldWidget> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        labelStyle: const TextStyle(color: AppColors.silver),
        hintStyle: const TextStyle(color: AppColors.borderGray),
        filled: true,
        fillColor: AppColors.midDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.comfortable),
          borderSide: const BorderSide(color: AppColors.borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.comfortable),
          borderSide: const BorderSide(color: AppColors.borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.comfortable),
          borderSide: const BorderSide(color: AppColors.spotifyGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.comfortable),
          borderSide: const BorderSide(color: AppColors.negativeRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.negativeRed.opacity > 0 ? AppRadius.comfortable : AppRadius.comfortable),
          borderSide: const BorderSide(color: AppColors.negativeRed, width: 1.5),
        ),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.silver,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}
