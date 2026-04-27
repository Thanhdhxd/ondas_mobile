import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_radius.dart';

class PlayerArtworkWidget extends StatelessWidget {
  final String? coverUrl;
  final double size;

  const PlayerArtworkWidget({
    super.key,
    required this.coverUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.comfortable),
        color: AppColors.darkCard,
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.comfortable),
        child: coverUrl != null
            ? Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const _ArtworkPlaceholder(),
              )
            : const _ArtworkPlaceholder(),
      ),
    );
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.midCard,
      child: const Icon(
        Icons.music_note,
        color: AppColors.silver,
        size: 64,
      ),
    );
  }
}
