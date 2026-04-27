import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_radius.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';

class PlaylistSongTileWidget extends StatelessWidget {
  final PlaylistSongItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const PlaylistSongTileWidget({
    super.key,
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final song = item.song;
    final minutes = song.durationSeconds ~/ 60;
    final seconds = (song.durationSeconds % 60).toString().padLeft(2, '0');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.subtle),
        child: SizedBox(
          width: 48,
          height: 48,
          child: song.coverUrl != null
              ? Image.network(
                  song.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _placeholder,
                )
              : _placeholder,
        ),
      ),
      title: Text(
        song.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.white,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$minutes:$seconds',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.silver,
            ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline, color: AppColors.silver),
        onPressed: onRemove,
        tooltip: 'Xóa khỏi playlist',
      ),
      onTap: onTap,
    );
  }

  Widget get _placeholder => Container(
        color: AppColors.midCard,
        child: const Icon(Icons.music_note, color: AppColors.silver, size: 24),
      );
}
