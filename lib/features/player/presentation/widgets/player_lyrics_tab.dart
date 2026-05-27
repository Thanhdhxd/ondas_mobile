import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/localization/language_cubit.dart';
import 'package:ondas_mobile/core/localization/str_enum.dart';
import 'package:ondas_mobile/core/localization/translations.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/lyrics/domain/entities/lyrics.dart';
import 'package:ondas_mobile/features/lyrics/presentation/bloc/lyrics_bloc.dart';
import 'package:ondas_mobile/features/lyrics/presentation/bloc/lyrics_event.dart';
import 'package:ondas_mobile/features/lyrics/presentation/bloc/lyrics_state.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_state.dart';

const _syncedFocusAlignment = 0.42;
const _syncedPaddingFactor = 0.45;

class PlayerLyricsTab extends StatefulWidget {
  const PlayerLyricsTab({super.key});

  @override
  State<PlayerLyricsTab> createState() => _PlayerLyricsTabState();
}

class _PlayerLyricsTabState extends State<PlayerLyricsTab> {
  @override
  void initState() {
    super.initState();
    _requestLyricsForCurrentSong();
  }

  void _requestLyricsForCurrentSong() {
    final songId = context.read<PlayerBloc>().state.currentSong?.id;
    final lyricsBloc = context.read<LyricsBloc>();
    if (songId == null) {
      lyricsBloc.add(const LyricsCleared());
    } else {
      lyricsBloc.add(LyricsRequested(songId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.watch<LanguageCubit>().state;
    return BlocListener<PlayerBloc, PlayerState>(
      listenWhen: (prev, curr) => prev.currentSong?.id != curr.currentSong?.id,
      listener: (context, state) {
        final songId = state.currentSong?.id;
        final lyricsBloc = context.read<LyricsBloc>();
        if (songId == null) {
          lyricsBloc.add(const LyricsCleared());
        } else {
          lyricsBloc.add(LyricsRequested(songId));
        }
      },
      child: BlocBuilder<LyricsBloc, LyricsState>(
        builder: (context, state) {
          return switch (state) {
            LyricsLoading() => _LoadingView(langCode: l),
            LyricsNotFound() => _EmptyView(langCode: l),
            LyricsFailure(:final message) => _ErrorView(
                message: message,
                langCode: l,
              ),
            LyricsLoaded(:final lyrics) => _LyricsContent(
                lyrics: lyrics,
                langCode: l,
              ),
            _ => _EmptyView(langCode: l),
          };
        },
      ),
    );
  }
}

class _LyricsContent extends StatelessWidget {
  final Lyrics lyrics;
  final String langCode;

  const _LyricsContent({required this.lyrics, required this.langCode});

  @override
  Widget build(BuildContext context) {
    if (lyrics.hasSynced) {
      if (lyrics.syncedLines.isEmpty) {
        return _EmptyView(langCode: langCode);
      }
      return _SyncedLyricsView(lines: lyrics.syncedLines);
    }

    final text = lyrics.plainText?.trim();
    if (text == null || text.isEmpty) {
      return _EmptyView(langCode: langCode);
    }
    return _PlainLyricsView(text: text);
  }
}

class _LoadingView extends StatelessWidget {
  final String langCode;

  const _LoadingView({required this.langCode});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.spotifyGreen),
          const SizedBox(height: AppSpacing.base),
          Text(
            t(Str.playerLyricsLoading, langCode),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.silver,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String langCode;

  const _EmptyView({required this.langCode});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.silver,
          fontWeight: FontWeight.w600,
        );
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.borderGray,
        );

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lyrics_outlined, size: 64, color: AppColors.silver),
          const SizedBox(height: AppSpacing.base),
          Text(t(Str.playerLyricsEmptyTitle, langCode), style: titleStyle),
          const SizedBox(height: AppSpacing.sm),
          Text(t(Str.playerLyricsEmptySubtitle, langCode), style: subtitleStyle),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final String langCode;

  const _ErrorView({required this.message, required this.langCode});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.silver,
          fontWeight: FontWeight.w600,
        );
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.borderGray,
        );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.silver),
            const SizedBox(height: AppSpacing.base),
            Text(
              t(Str.playerLyricsError, langCode),
              style: titleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: subtitleStyle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _PlainLyricsView extends StatelessWidget {
  final String text;

  const _PlainLyricsView({required this.text});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.nearWhite,
          fontSize: 18,
          height: 1.6,
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }
}

class _SyncedLyricsView extends StatefulWidget {
  final List<SyncedLyricsLine> lines;

  const _SyncedLyricsView({required this.lines});

  @override
  State<_SyncedLyricsView> createState() => _SyncedLyricsViewState();
}

class _SyncedLyricsViewState extends State<_SyncedLyricsView> {
  final ScrollController _scrollController = ScrollController();
  late List<GlobalKey> _lineKeys;
  int _lastActiveIndex = -1;

  @override
  void initState() {
    super.initState();
    _lineKeys = List.generate(widget.lines.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant _SyncedLyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lines.length != widget.lines.length) {
      _lineKeys = List.generate(widget.lines.length, (_) => GlobalKey());
      _lastActiveIndex = -1;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActive(int index) {
    if (index < 0 || index >= _lineKeys.length) return;
    final context = _lineKeys[index].currentContext;
    if (context == null) return;

    Scrollable.ensureVisible(
      context,
      alignment: _syncedFocusAlignment,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (prev, curr) => prev.position != curr.position,
      builder: (context, state) {
        final activeIndex = _findActiveLineIndex(widget.lines, state.position);
        if (activeIndex != _lastActiveIndex) {
          _lastActiveIndex = activeIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _scrollToActive(activeIndex);
          });
        }

        final theme = Theme.of(context);
        final inactiveStyle = theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.silver,
              fontSize: 18,
              height: 1.4,
            ) ??
            const TextStyle(color: AppColors.silver, fontSize: 18, height: 1.4);
        final activeStyle = theme.textTheme.titleMedium?.copyWith(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ) ??
            const TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.4,
            );

        return LayoutBuilder(
          builder: (context, constraints) {
            final verticalPadding = constraints.maxHeight * _syncedPaddingFactor;
            return ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: verticalPadding,
                bottom: verticalPadding,
              ),
              itemBuilder: (context, index) {
                final line = widget.lines[index];
                final isActive = index == activeIndex;
                final style = isActive ? activeStyle : inactiveStyle;
                return Align(
                  key: _lineKeys[index],
                  alignment: Alignment.center,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: style,
                    child: Text(
                      line.lineText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.base),
              itemCount: widget.lines.length,
            );
          },
        );
      },
    );
  }
}

int _findActiveLineIndex(List<SyncedLyricsLine> lines, Duration position) {
  final positionMs = position.inMilliseconds;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final start = line.startMs;
    final end = line.endMs ??
        (i + 1 < lines.length ? lines[i + 1].startMs : null);
    if (positionMs >= start && (end == null || positionMs < end)) {
      return i;
    }
  }
  return -1;
}
