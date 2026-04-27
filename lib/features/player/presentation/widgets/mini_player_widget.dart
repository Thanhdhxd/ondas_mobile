import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_radius.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/player/domain/entities/player_status.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_state.dart';
import 'package:ondas_mobile/features/player/presentation/widgets/player_artwork_widget.dart';
import 'package:ondas_mobile/features/player/presentation/widgets/player_controls_widget.dart';

/// Mini player bar displayed at the bottom of [MainShellScreen].
/// Visible only when [PlayerState.status] is not [PlayerStatus.idle].
/// Tap anywhere → push /player (full screen).
class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (prev, curr) =>
          prev.status != curr.status ||
          prev.currentSong != curr.currentSong ||
          prev.position != curr.position ||
          prev.duration != curr.duration,
      builder: (context, state) {
        if (state.status == PlayerStatus.idle || state.currentSong == null) {
          return const SizedBox.shrink();
        }
        return _MiniPlayerBar(state: state);
      },
    );
  }
}

class _MiniPlayerBar extends StatelessWidget {
  final PlayerState state;

  const _MiniPlayerBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = state.duration.inMilliseconds > 0
        ? (state.position.inMilliseconds / state.duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    final bloc = context.read<PlayerBloc>();

    return GestureDetector(
      onTap: () => context.push('/player'),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(AppRadius.comfortable),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  PlayerArtworkWidget(
                    coverUrl: state.currentSong?.coverUrl,
                    size: 44,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.currentSong?.title ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          state.currentSong?.artistDisplay ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PlayerControlsWidget(
                    status: state.status,
                    hasPrevious: state.hasPrevious,
                    hasNext: state.hasNext,
                    onPlay: () => bloc.add(const ResumeRequested()),
                    onPause: () => bloc.add(const PauseRequested()),
                    onSkipNext: () => bloc.add(const SkipNextRequested()),
                    onSkipPrevious: () => bloc.add(const SkipPreviousRequested()),
                    onRepeatModeToggle: () {},
                    compact: true,
                  ),
                ],
              ),
            ),
            // Progress bar at bottom of mini player
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.comfortable),
                bottomRight: Radius.circular(AppRadius.comfortable),
              ),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.borderGray,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.spotifyGreen,
                ),
                minHeight: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
