import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/localization/str_enum.dart';
import 'package:ondas_mobile/core/localization/translations.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/features/stats/domain/entities/listening_time_stats.dart';

class ListeningTimeCard extends StatelessWidget {
  final ListeningTimeStats stats;

  const ListeningTimeCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final langCode = lang(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.midCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.spotifyGreen, size: 28),
              const SizedBox(width: 12),
              Text(
                t(Str.statsListeningTime, langCode),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                context,
                value: stats.totalListeningHours > 0
                    ? '${stats.totalListeningHours.toStringAsFixed(1)} ${t(Str.statsHours, langCode)}'
                    : '${stats.totalListeningMinutes.toStringAsFixed(1)} ${t(Str.statsMinutes, langCode)}',
                label: t(Str.statsListeningTime, langCode),
              ),
              Container(width: 1, height: 40, color: AppColors.borderGray),
              _buildStatItem(
                context,
                value: stats.totalSongsPlayed.toString(),
                label: t(Str.statsTotalSongsPlayed, langCode),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required String value, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.silver,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
