import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';

class CreatePlaylistDialog extends StatefulWidget {
  const CreatePlaylistDialog({super.key});

  @override
  State<CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
        'Playlist mới',
        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          key: const Key('createPlaylistDialog_nameField'),
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'Tên playlist',
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
            if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên';
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Hủy',
            style: TextStyle(color: AppColors.silver),
          ),
        ),
        TextButton(
          key: const Key('createPlaylistDialog_confirmButton'),
          onPressed: _submit,
          child: const Text(
            'Tạo',
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
