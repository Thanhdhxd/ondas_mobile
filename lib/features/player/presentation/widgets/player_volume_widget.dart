import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';

/// Pure presentational volume slider widget.
///
/// volume: [0.0 - 1.0]
class PlayerVolumeWidget extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onVolumeChanged;

  const PlayerVolumeWidget({
    super.key,
    required this.volume,
    required this.onVolumeChanged,
  });

  IconData get _volumeIcon {
    if (volume == 0) return Icons.volume_off_rounded;
    if (volume < 0.5) return Icons.volume_down_rounded;
    return Icons.volume_up_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(_volumeIcon, color: AppColors.silver, size: 20),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.silver,
              inactiveTrackColor: AppColors.borderGray,
              thumbColor: AppColors.silver,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              trackHeight: 2,
            ),
            child: Slider(
              key: const Key('playerVolume_slider'),
              value: volume.clamp(0.0, 1.0),
              onChanged: onVolumeChanged,
            ),
          ),
        ),
        const Icon(Icons.volume_up_rounded, color: AppColors.silver, size: 20),
      ],
    );
  }
}
