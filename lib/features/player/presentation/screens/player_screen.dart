import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/player/domain/entities/player_status.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_state.dart';
import 'package:ondas_mobile/features/player/presentation/widgets/player_artwork_widget.dart';
import 'package:ondas_mobile/features/player/presentation/widgets/player_controls_widget.dart';
import 'package:ondas_mobile/features/player/presentation/widgets/player_info_widget.dart';
import 'package:ondas_mobile/features/player/presentation/widgets/player_lyrics_tab.dart';
import 'package:ondas_mobile/features/player/presentation/widgets/player_queue_tab.dart';
import 'package:ondas_mobile/features/player/presentation/widgets/player_seekbar_widget.dart';
import 'package:ondas_mobile/features/player/presentation/widgets/player_volume_widget.dart';
import 'package:ondas_mobile/features/playlist/presentation/widgets/save_to_playlist_bottom_sheet.dart';
import 'package:ondas_mobile/features/favorites/presentation/widgets/favorite_button_widget.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  static const _tabs = ['Playing', 'Lyrics', 'Queue'];

  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.nearBlack,
          body: Stack(
            children: [
              _PlayerBackground(coverUrl: state.currentSong?.coverUrl),
              SafeArea(
                child: Column(
                  children: [
                    _PlayerAppBar(),
                    _TabIndicator(
                      tabs: _tabs,
                      currentIndex: _currentPage,
                      onTap: (i) => _pageController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ),
                    Expanded(
                      child: state.status == PlayerStatus.idle
                          ? const _IdleView()
                          : PageView(
                              controller: _pageController,
                              onPageChanged: _onPageChanged,
                              children: [
                                _PlayerContent(state: state),
                                const PlayerLyricsTab(),
                                const PlayerQueueTab(),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Tab indicator ─────────────────────────────────────────────────────────────

class _TabIndicator extends StatelessWidget {
  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TabIndicator({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(tabs.length, (i) {
          final isSelected = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.spotifyGreen.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  color: isSelected ? AppColors.spotifyGreen : AppColors.silver,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 13,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Background blur ──────────────────────────────────────────────────────────

class _PlayerBackground extends StatelessWidget {
  final String? coverUrl;

  const _PlayerBackground({this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (coverUrl != null)
            Image.network(
              coverUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: AppColors.nearBlack),
            )
          else
            const ColoredBox(color: AppColors.nearBlack),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
            child: const ColoredBox(color: Color(0xCC121212)),
          ),
        ],
      ),
    );
  }
}

// ── App bar ──────────────────────────────────────────────────────────────────

class _PlayerAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('playerScreen_backButton'),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
            color: AppColors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Now Playing',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
          // Placeholder for options menu (e.g., add to playlist, share)
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ── Idle state ───────────────────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  const _IdleView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_off_rounded, size: 64, color: AppColors.silver),
          SizedBox(height: AppSpacing.base),
          Text(
            'No song playing',
            style: TextStyle(color: AppColors.silver, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ── Main content ─────────────────────────────────────────────────────────────

class _PlayerContent extends StatelessWidget {
  final PlayerState state;

  const _PlayerContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),
            _ArtworkSection(coverUrl: state.currentSong?.coverUrl),
            const SizedBox(height: AppSpacing.xxl),
            _InfoSection(state: state),
            const SizedBox(height: AppSpacing.xl),
            _SeekbarSection(state: state),
            const SizedBox(height: AppSpacing.lg),
            _ControlsSection(state: state),
            const SizedBox(height: AppSpacing.xl),
            _VolumeSection(state: state),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _ArtworkSection extends StatelessWidget {
  final String? coverUrl;

  const _ArtworkSection({this.coverUrl});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width - AppSpacing.xl * 2;
    return PlayerArtworkWidget(
      key: const Key('playerScreen_artwork'),
      coverUrl: coverUrl,
      size: size,
    );
  }
}

class _InfoSection extends StatelessWidget {
  final PlayerState state;

  const _InfoSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final song = state.currentSong;
    return Row(
      children: [
        Expanded(
          child: PlayerInfoWidget(
            key: const Key('playerScreen_info'),
            songTitle: song?.title ?? '',
            artistDisplay: song?.artistDisplay ?? '',
          ),
        ),
        if (song != null)
          FavoriteButtonWidget(
            key: ValueKey('playerScreen_favorite_${song.id}'),
            songId: song.id,
            iconSize: 28,
            activeColor: Colors.redAccent,
            inactiveColor: AppColors.silver,
          ),
      ],
    );
  }
}

class _SeekbarSection extends StatelessWidget {
  final PlayerState state;

  const _SeekbarSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return PlayerSeekbarWidget(
      key: const Key('playerScreen_seekbar'),
      position: state.position,
      duration: state.duration,
      onSeek: (position) =>
          context.read<PlayerBloc>().add(SeekRequested(position)),
    );
  }
}

class _ControlsSection extends StatelessWidget {
  final PlayerState state;

  const _ControlsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    final song = state.currentSong;
    return PlayerControlsWidget(
      key: const Key('playerScreen_controls'),
      status: state.status,
      hasPrevious: state.hasPrevious,
      hasNext: state.hasNext,
      repeatMode: state.repeatMode,
      onPlay: () => bloc.add(const ResumeRequested()),
      onPause: () => bloc.add(const PauseRequested()),
      onSkipNext: () => bloc.add(const SkipNextRequested()),
      onSkipPrevious: () => bloc.add(const SkipPreviousRequested()),
      onRepeatModeToggle: () => bloc.add(const RepeatModeToggled()),
      onSave: song == null
          ? null
          : () => SaveToPlaylistBottomSheet.show(
                context,
                songId: song.id,
                coverUrl: song.coverUrl,
              ),
    );
  }
}

class _VolumeSection extends StatelessWidget {
  final PlayerState state;

  const _VolumeSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return PlayerVolumeWidget(
      key: const Key('playerScreen_volume'),
      volume: state.volume,
      onVolumeChanged: (v) =>
          context.read<PlayerBloc>().add(VolumeChanged(v)),
    );
  }
}
