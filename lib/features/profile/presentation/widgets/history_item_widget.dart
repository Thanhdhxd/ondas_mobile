import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/profile/domain/entities/play_history_item.dart';

class HistoryItemWidget extends StatelessWidget {
  final PlayHistoryItem item;
  final VoidCallback onDelete;

  const HistoryItemWidget({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final song = item.song;

    return ListTile(
      key: Key('historyItem_${item.id}'),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      leading: _CoverArt(coverUrl: song.coverUrl),
      title: Text(
        song.title,
        style: textTheme.bodyMedium?.copyWith(color: AppColors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatPlayedAt(item.playedAt),
        style: textTheme.bodySmall?.copyWith(color: AppColors.silver),
      ),
      trailing: IconButton(
        key: Key('historyItem_delete_${item.id}'),
        icon: const Icon(Icons.close, color: AppColors.silver, size: 20),
        onPressed: onDelete,
        tooltip: 'Remove from history',
      ),
    );
  }

  String _formatPlayedAt(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';

    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}

class _CoverArt extends StatelessWidget {
  final String? coverUrl;

  const _CoverArt({this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 48,
        height: 48,
        child: coverUrl != null
            ? Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder,
              )
            : _placeholder,
      ),
    );
  }

  Widget get _placeholder => Container(
        color: AppColors.darkCard,
        child: const Icon(Icons.music_note, color: AppColors.silver, size: 24),
      );
}
