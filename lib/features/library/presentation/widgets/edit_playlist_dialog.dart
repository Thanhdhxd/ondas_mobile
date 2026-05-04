import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';

class EditPlaylistDialog extends StatefulWidget {
  final String initialName;

  const EditPlaylistDialog({super.key, required this.initialName});

  @override
  State<EditPlaylistDialog> createState() => _EditPlaylistDialogState();
}

class _EditPlaylistDialogState extends State<EditPlaylistDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Edit Playlist',
        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          key: const Key('editPlaylistDialog_nameField'),
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'Playlist Name',
            hintStyle: const TextStyle(color: AppColors.silver),
            filled: true,
            fillColor: AppColors.midDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.spotifyGreen),
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Please enter a name';
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.silver)),
        ),
        TextButton(
          key: const Key('editPlaylistDialog_confirmButton'),
          onPressed: _submit,
          child: const Text(
            'Save',
            style: TextStyle(
              color: AppColors.spotifyGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
