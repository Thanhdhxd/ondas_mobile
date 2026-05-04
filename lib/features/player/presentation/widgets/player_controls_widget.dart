import 'package:flutter/material.dart' hide RepeatMode;
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/features/player/domain/entities/player_status.dart';

/// Pure presentational widget — no BLoC dependency.
///
/// Used by:
/// - [PlayerScreen] — full size (compact: false)
/// - [MiniPlayerWidget] — compact (compact: true)
/// - Future: Notification overlay, Lock Screen (same widget, compact: true)
class PlayerControlsWidget extends StatelessWidget {
  final PlayerStatus status;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onSkipNext;
  final VoidCallback onSkipPrevious;
  final RepeatMode repeatMode;
  final VoidCallback onRepeatModeToggle;

  /// Called when the save/bookmark button is tapped. Only shown when not compact.
  final VoidCallback? onSave;

  /// When true: smaller icons, no seek affordance — suitable for mini player
  /// and notification controls.
  final bool compact;

  const PlayerControlsWidget({
    super.key,
    required this.status,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPlay,
    required this.onPause,
    required this.onSkipNext,
    required this.onSkipPrevious,
    this.repeatMode = RepeatMode.off,
    required this.onRepeatModeToggle,
    this.onSave,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final playButtonSize = compact ? 36.0 : 64.0;
    final skipButtonSize = compact ? 20.0 : 32.0;
    final iconSpacing = compact ? 8.0 : 24.0;

    final isLoading = status == PlayerStatus.loading;
    final isPlaying = status == PlayerStatus.playing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!compact)
          _RepeatButton(
            key: const Key('playerControls_repeatButton'),
            repeatMode: repeatMode,
            onTap: onRepeatModeToggle,
          )
        else
          const SizedBox.shrink(),
        SizedBox(width: compact ? 0 : iconSpacing),
        _SkipButton(
          key: const Key('playerControls_skipPreviousButton'),
          icon: Icons.skip_previous_rounded,
          size: skipButtonSize,
          enabled: hasPrevious && !isLoading,
          onTap: onSkipPrevious,
        ),
        SizedBox(width: iconSpacing),
        _PlayPauseButton(
          key: const Key('playerControls_playPauseButton'),
          isPlaying: isPlaying,
          isLoading: isLoading,
          size: playButtonSize,
          onPlay: onPlay,
          onPause: onPause,
        ),
        SizedBox(width: iconSpacing),
        _SkipButton(
          key: const Key('playerControls_skipNextButton'),
          icon: Icons.skip_next_rounded,
          size: skipButtonSize,
          enabled: hasNext && !isLoading,
          onTap: onSkipNext,
        ),
        if (!compact)
          SizedBox(width: iconSpacing),
        if (!compact)
          _SaveButton(
            key: const Key('playerControls_saveButton'),
            onTap: onSave,
          ),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final double size;
  final VoidCallback onPlay;
  final VoidCallback onPause;

  const _PlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.isLoading,
    required this.size,
    required this.onPlay,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          color: AppColors.white,
          strokeWidth: 3,
        ),
      );
    }

    return GestureDetector(
      onTap: isPlaying ? onPause : onPlay,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: AppColors.nearBlack,
          size: size * 0.55,
        ),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool enabled;
  final VoidCallback onTap;

  const _SkipButton({
    super.key,
    required this.icon,
    required this.size,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Icon(
        icon,
        color: enabled ? AppColors.white : AppColors.silver,
        size: size,
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _SaveButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        // Thay thành icon add to list
        Icons.playlist_add_rounded,
        color: onTap != null ? AppColors.white : AppColors.silver,
        size: 24,
      ),
    );
  }
}

class _RepeatButton extends StatelessWidget {
  final RepeatMode repeatMode;
  final VoidCallback onTap;

  const _RepeatButton({
    super.key,
    required this.repeatMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = repeatMode != RepeatMode.off;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            repeatMode == RepeatMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            color: isActive ? AppColors.spotifyGreen : AppColors.silver,
            size: 24,
          ),
        ],
      ),
    );
  }
}
