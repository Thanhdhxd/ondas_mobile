import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_mobile/core/localization/language_cubit.dart';
import 'package:ondas_mobile/core/localization/str_enum.dart';
import 'package:ondas_mobile/core/localization/translations.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/core/widgets/reconnect_listener.dart';
import 'package:ondas_mobile/features/favorites/domain/entities/favorite_song.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:ondas_mobile/features/favorites/presentation/widgets/favorite_song_item_widget.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';

/// Embeddable favorites list — expects [FavoritesBloc] in context.
/// Does NOT create its own BlocProvider or Scaffold.
class FavoritesListWidget extends StatelessWidget {
  const FavoritesListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.watch<LanguageCubit>().state;
    return ReconnectListener(
      shouldReconnect: () =>
          context.read<FavoritesBloc>().state is FavoritesListError,
      onReconnect: () =>
          context.read<FavoritesBloc>().add(const FavoritesListRequested()),
      child: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) => switch (state) {
          FavoritesInitial() => const SizedBox.shrink(),
          FavoritesListLoading() => const _LoadingView(),
          FavoritesListError(:final message) => _ErrorView(
              message: message,
              langCode: l,
              onRetry: () => context
                  .read<FavoritesBloc>()
                  .add(const FavoritesListRequested()),
            ),
          FavoritesListLoaded(:final items, :final hasMore, :final currentPage, :final isLoadingMore) =>
            _FavoritesScrollList(
              state: FavoritesListLoaded(
                items: items,
                hasMore: hasMore,
                currentPage: currentPage,
                isLoadingMore: isLoadingMore,
              ),
              langCode: l,
            ),
        },
      ),
    );
  }
}

// ── Loading ──────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.spotifyGreen),
    );
  }
}

// ── Error ────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final String langCode;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.langCode,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.negativeRed),
            const SizedBox(height: AppSpacing.base),
            Text(
              t(Str.favoritesLoadError, langCode),
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(t(Str.retry, langCode)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scrollable list ───────────────────────────────────────────────────────────

class _FavoritesScrollList extends StatefulWidget {
  final FavoritesListLoaded state;
  final String langCode;

  const _FavoritesScrollList({
    required this.state,
    required this.langCode,
  });

  @override
  State<_FavoritesScrollList> createState() => _FavoritesScrollListState();
}

class _FavoritesScrollListState extends State<_FavoritesScrollList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<FavoritesBloc>().add(const FavoritesLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    if (state.items.isEmpty) {
      return _EmptyView(langCode: widget.langCode);
    }

    return RefreshIndicator(
      color: AppColors.spotifyGreen,
      onRefresh: () async =>
          context.read<FavoritesBloc>().add(const FavoritesListRequested()),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.base),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.spotifyGreen),
              ),
            );
          }
          return _DismissibleFavoriteItem(item: state.items[index]);
        },
      ),
    );
  }
}

// ── Dismissible row ──────────────────────────────────────────────────────────

class _DismissibleFavoriteItem extends StatelessWidget {
  final FavoriteItem item;

  const _DismissibleFavoriteItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('favorite_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        color: AppColors.negativeRed,
        child: const Icon(Icons.favorite_border_rounded, color: AppColors.white),
      ),
      onDismissed: (_) => context
          .read<FavoritesBloc>()
          .add(FavoriteRemovedFromList(item.song.id)),
      child: FavoriteSongItemWidget(
        item: item,
        onTap: () => _playSong(context, item.song),
      ),
    );
  }

  void _playSong(BuildContext context, FavoriteSong song) {
    context.read<PlayerBloc>().add(
          PlaySongRequested(
            songs: [
              Song(
                id: song.id,
                title: song.title,
                artistNames: song.artistNames,
                coverUrl: song.coverUrl,
                audioUrl: song.audioUrl,
                durationSeconds: song.durationSeconds,
              ),
            ],
            index: 0,
            source: 'favorites',
          ),
        );
    context.push('/player');
  }
}

// ── Empty ─────────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final String langCode;
  const _EmptyView({required this.langCode});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite_border_rounded,
            size: 64,
            color: AppColors.silver,
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            t(Str.favoritesEmptyTitle, langCode),
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.silver),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            t(Str.favoritesEmptySubtitle, langCode),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.silver),
          ),
        ],
      ),
    );
  }
}
