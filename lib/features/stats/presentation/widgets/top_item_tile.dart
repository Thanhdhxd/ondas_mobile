import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/localization/str_enum.dart';
import 'package:ondas_mobile/core/localization/translations.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';

class TopItemTile extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final int playCount;
  final bool isArtist;

  const TopItemTile({
    super.key,
    required this.index,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.playCount,
    this.isArtist = false,
  });

  @override
  Widget build(BuildContext context) {
    final langCode = lang(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#$index',
              style: const TextStyle(
                color: AppColors.silver,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: isArtist ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isArtist ? null : BorderRadius.circular(8),
              color: AppColors.midDark,
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? Icon(
                    isArtist ? Icons.person : Icons.music_note,
                    color: AppColors.silver,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.silver,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                playCount.toString(),
                style: const TextStyle(
                  color: AppColors.spotifyGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                t(Str.statsPlayCount, langCode),
                style: const TextStyle(
                  color: AppColors.silver,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
