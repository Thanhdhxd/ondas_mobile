import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/localization/language_cubit.dart';
import 'package:ondas_mobile/core/localization/str_enum.dart';
import 'package:ondas_mobile/core/localization/translations.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/lyrics/presentation/bloc/lyrics_bloc.dart';
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
  static const _tabKeys = [
    Str.playerTabPlaying,
    Str.playerTabLyrics,
    Str.playerTabQueue,
  ];

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
    final l = context.watch<LanguageCubit>().state;
    final tabs = _tabKeys.map((key) => t(key, l)).toList();
    final safeIndex = tabs.isEmpty
        ? 0
        : _currentPage.clamp(0, tabs.length - 1).toInt();
    final currentTitle = tabs.isEmpty ? '' : tabs[safeIndex];
    return BlocListener<PlayerBloc, PlayerState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == PlayerStatus.error,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              content: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.nearBlack.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.redAccent.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.redAccent,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              margin: const EdgeInsets.all(AppSpacing.base),
            ),
          );
        }
      },
      child: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.nearBlack,
            body: Stack(
              children: [
                _PlayerBackground(coverUrl: state.currentSong?.coverUrl),
                SafeArea(
                  child: Column(
                    children: [
                      _PlayerAppBar(title: currentTitle),
                      _TabIndicator(
                        tabCount: tabs.length,
                        currentIndex: _currentPage,
                        onTap: (i) => _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      ),
                      Expanded(
                        child: state.status == PlayerStatus.idle
                            ? _IdleView(langCode: l)
                            : PageView(
                                controller: _pageController,
                                onPageChanged: _onPageChanged,
                                children: [
                                  _PlayerContent(state: state),
                                  BlocProvider<LyricsBloc>(
                                    create: (_) => sl<LyricsBloc>(),
                                    child: const PlayerLyricsTab(),
                                  ),
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
      ),
    );
  }
}

// ── Tab indicator ─────────────────────────────────────────────────────────────

class _TabIndicator extends StatelessWidget {
  final int tabCount;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TabIndicator({
    required this.tabCount,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tabCount <= 0) return const SizedBox.shrink();
    const barHeight = 6.0;
    const indicatorHeight = 4.0;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fullWidth = constraints.maxWidth;
          final segmentWidth = fullWidth / tabCount;
          final safeIndex = currentIndex.clamp(0, tabCount - 1).toInt();
          final left = segmentWidth * safeIndex;

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (details) {
              final dx = details.localPosition.dx.clamp(0.0, fullWidth);
              final tappedIndex = (dx / segmentWidth).floor();
              onTap(tappedIndex.clamp(0, tabCount - 1));
            },
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: AppColors.midDark,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  left: left,
                  top: (barHeight - indicatorHeight) / 2,
                  child: Container(
                    width: segmentWidth,
                    height: indicatorHeight,
                    decoration: BoxDecoration(
                      color: AppColors.spotifyGreen,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
  final String title;

  const _PlayerAppBar({required this.title});

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
              title,
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
  final String langCode;

  const _IdleView({required this.langCode});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.music_off_rounded, size: 64, color: AppColors.silver),
          const SizedBox(height: AppSpacing.base),
          Text(
            t(Str.playerNoSongPlaying, langCode),
            style: const TextStyle(color: AppColors.silver, fontSize: 16),
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
