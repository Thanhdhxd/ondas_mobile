import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';

class ChangePasswordDialogWidget extends StatefulWidget {
  final void Function(String currentPassword, String newPassword) onSubmit;

  const ChangePasswordDialogWidget({super.key, required this.onSubmit});

  @override
  State<ChangePasswordDialogWidget> createState() => _ChangePasswordDialogWidgetState();
}

class _ChangePasswordDialogWidgetState extends State<ChangePasswordDialogWidget> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _currentPasswordController.text,
        _newPasswordController.text,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: Text('Change Password', style: textTheme.titleMedium?.copyWith(color: AppColors.white)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: const Key('changePasswordDialog_currentPasswordField'),
              controller: _currentPasswordController,
              obscureText: _obscureCurrent,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                labelText: 'Current Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.silver,
                  ),
                  onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Current password is required';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              key: const Key('changePasswordDialog_newPasswordField'),
              controller: _newPasswordController,
              obscureText: _obscureNew,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.silver,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              validator: (v) {
                if (v == null || v.length < 8) return 'Minimum 8 characters';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              key: const Key('changePasswordDialog_confirmPasswordField'),
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.silver,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your new password';
                if (v != _newPasswordController.text) return 'Passwords do not match';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('changePasswordDialog_cancelButton'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: AppColors.silver)),
        ),
        ElevatedButton(
          key: const Key('changePasswordDialog_submitButton'),
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
