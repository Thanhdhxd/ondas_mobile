import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';

class CreatePlaylistBottomSheet extends StatefulWidget {
  final void Function(String name, String? description, bool isPublic) onConfirm;

  const CreatePlaylistBottomSheet({super.key, required this.onConfirm});

  @override
  State<CreatePlaylistBottomSheet> createState() =>
      _CreatePlaylistBottomSheetState();
}

class _CreatePlaylistBottomSheetState
    extends State<CreatePlaylistBottomSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isPublic = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final name = _nameController.text.trim();
    final desc =
        _descController.text.trim().isEmpty ? null : _descController.text.trim();
    widget.onConfirm(name, desc, _isPublic);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tạo playlist mới',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.base),
            TextFormField(
              key: const Key('createPlaylist_nameField'),
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                labelText: 'Tên playlist',
                hintText: 'Nhập tên playlist...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Tên playlist không được để trống';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              key: const Key('createPlaylist_descriptionField'),
              controller: _descController,
              style: const TextStyle(color: AppColors.white),
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Mô tả (tuỳ chọn)',
                hintText: 'Nhập mô tả...',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text(
                  'Công khai',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.silver,
                      ),
                ),
                const Spacer(),
                Switch(
                  key: const Key('createPlaylist_isPublicSwitch'),
                  value: _isPublic,
                  activeThumbColor: AppColors.spotifyGreen,
                  onChanged: (v) => setState(() => _isPublic = v),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            ElevatedButton(
              key: const Key('createPlaylist_confirmButton'),
              onPressed: _submit,
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
  }
}
