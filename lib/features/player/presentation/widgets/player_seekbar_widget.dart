import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';

/// Pure presentational seekbar widget.
///
/// Reusable for PlayerScreen. For Notification/Lock Screen, a simpler
/// LinearProgressIndicator variant can wrap the same data.
class PlayerSeekbarWidget extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const PlayerSeekbarWidget({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  State<PlayerSeekbarWidget> createState() => _PlayerSeekbarWidgetState();
}

class _PlayerSeekbarWidgetState extends State<PlayerSeekbarWidget> {
  // While dragging, show the drag value instead of stream position
  double? _draggingValue;

  double get _value {
    if (_draggingValue != null) return _draggingValue!;
    if (widget.duration.inMilliseconds == 0) return 0;
    return (widget.position.inMilliseconds / widget.duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.white,
            inactiveTrackColor: AppColors.borderGray,
            thumbColor: AppColors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            trackHeight: 3,
          ),
          child: Slider(
            key: const Key('playerSeekbar_slider'),
            value: _value,
            onChangeStart: (_) => setState(() => _draggingValue = _value),
            onChanged: (v) => setState(() => _draggingValue = v),
            onChangeEnd: (v) {
              setState(() => _draggingValue = null);
              final seekTo = Duration(
                milliseconds: (v * widget.duration.inMilliseconds).round(),
              );
              widget.onSeek(seekTo);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(widget.position),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                _formatDuration(widget.duration),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
