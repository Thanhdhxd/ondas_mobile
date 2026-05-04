import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';

import 'package:ondas_mobile/features/player/presentation/bloc/player_state.dart';

class PlayerQueueTab extends StatelessWidget {
  const PlayerQueueTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        if (state.queue.isEmpty) {
          return const _EmptyQueue();
        }
        return _QueueList(
          queue: state.queue,
          currentIndex: state.currentIndex,
        );
      },
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.queue_music_rounded, size: 64, color: AppColors.silver),
          SizedBox(height: AppSpacing.base),
          Text(
            'Queue is empty',
            style: TextStyle(
              color: AppColors.silver,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Queue list ────────────────────────────────────────────────────────────────

class _QueueList extends StatelessWidget {
  final List<Song> queue;
  final int currentIndex;

  const _QueueList({
    required this.queue,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      itemCount: queue.length,
      itemBuilder: (context, index) {
        final song = queue[index];
        final isCurrent = index == currentIndex;
        return _QueueItem(
          song: song,
          isCurrent: isCurrent,
          index: index,
        );
      },
    );
  }
}

// ── Queue item ────────────────────────────────────────────────────────────────

class _QueueItem extends StatelessWidget {
  final Song song;
  final bool isCurrent;
  final int index;

  const _QueueItem({
    required this.song,
    required this.isCurrent,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('playerQueueTab_item_$index'),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: song.coverUrl != null
            ? Image.network(
                song.coverUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _FallbackCover(),
              )
            : const _FallbackCover(),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isCurrent ? AppColors.spotifyGreen : AppColors.white,
          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        song.artistDisplay,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.silver,
          fontSize: 12,
        ),
      ),
      trailing: isCurrent
          ? const Icon(
              Icons.equalizer_rounded,
              color: AppColors.spotifyGreen,
              size: 20,
            )
          : null,
      onTap: isCurrent
          ? null
          : () {
              final queue = context.read<PlayerBloc>().state.queue;
              context.read<PlayerBloc>().add(
                    PlaySongRequested(songs: queue, index: index),
                  );
            },
    );
  }
}

// ── Fallback cover ────────────────────────────────────────────────────────────

class _FallbackCover extends StatelessWidget {
  const _FallbackCover();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.midDark,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Icon(Icons.music_note_rounded, color: AppColors.silver, size: 24),
      ),
    );
  }
}
