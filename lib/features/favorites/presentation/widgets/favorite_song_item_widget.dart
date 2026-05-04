import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/favorites/domain/entities/favorite_song.dart';
import 'package:ondas_mobile/features/favorites/presentation/widgets/favorite_button_widget.dart';

class FavoriteSongItemWidget extends StatelessWidget {
  final FavoriteItem item;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const FavoriteSongItemWidget({
    super.key,
    required this.item,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      leading: _CoverImage(coverUrl: item.song.coverUrl),
      title: Text(
        item.song.title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        item.song.artistDisplay,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.silver,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: FavoriteButtonWidget(
        songId: item.song.id,
        iconSize: 22,
        activeColor: Colors.redAccent,
        inactiveColor: AppColors.silver,
      ),
      onTap: onTap,
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? coverUrl;

  const _CoverImage({this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 52,
        height: 52,
        child: coverUrl != null
            ? Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, _) => _Placeholder(),
              )
            : _Placeholder(),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkCard,
      child: const Icon(
        Icons.music_note_rounded,
        color: AppColors.silver,
        size: 24,
      ),
    );
  }
}
