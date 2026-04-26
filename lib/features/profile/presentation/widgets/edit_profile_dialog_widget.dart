import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';

class EditProfileDialogWidget extends StatefulWidget {
  final UserProfile userProfile;
  final void Function(String displayName) onSubmit;

  const EditProfileDialogWidget({
    super.key,
    required this.userProfile,
    required this.onSubmit,
  });

  @override
  State<EditProfileDialogWidget> createState() => _EditProfileDialogWidgetState();
}

class _EditProfileDialogWidgetState extends State<EditProfileDialogWidget> {
  late final TextEditingController _displayNameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.userProfile.displayName);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_displayNameController.text.trim());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: Text('Edit Profile', style: textTheme.titleMedium?.copyWith(color: AppColors.white)),
      content: Form(
        key: _formKey,
        child: TextFormField(
          key: const Key('editProfileDialog_displayNameField'),
          controller: _displayNameController,
          style: const TextStyle(color: AppColors.white),
          decoration: const InputDecoration(labelText: 'Display Name'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Display name is required';
            if (v.trim().length > 50) return 'Max 50 characters';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          key: const Key('editProfileDialog_cancelButton'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: AppColors.silver)),
        ),
        ElevatedButton(
          key: const Key('editProfileDialog_submitButton'),
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

