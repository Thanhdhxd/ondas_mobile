import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_event.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_state.dart';
import 'package:ondas_mobile/features/playlist/presentation/widgets/create_playlist_bottom_sheet.dart';
import 'package:ondas_mobile/features/playlist/presentation/widgets/playlist_card_widget.dart';

class PlaylistListScreen extends StatelessWidget {
  const PlaylistListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlaylistBloc>(
      create: (_) => sl<PlaylistBloc>()..add(const PlaylistLoadRequested()),
      child: const _PlaylistListView(),
    );
  }
}

class _PlaylistListView extends StatelessWidget {
  const _PlaylistListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        backgroundColor: AppColors.nearBlack,
        title: const Text(
          'Thư viện',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('playlistList_createFab'),
        backgroundColor: AppColors.spotifyGreen,
        onPressed: () => _showCreateBottomSheet(context),
        child: const Icon(Icons.add, color: AppColors.nearBlack),
      ),
      body: BlocConsumer<PlaylistBloc, PlaylistState>(
        listener: (context, state) {
          if (state is PlaylistFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.negativeRed,
              ),
            );
          }
        },
        builder: (context, state) => switch (state) {
          PlaylistLoading() => const _LoadingView(),
          PlaylistLoaded(:final playlists) ||
          PlaylistOperationSuccess(:final playlists) =>
            _ContentView(playlists: playlists),
          PlaylistFailure(:final message) => _ErrorView(
              message: message,
              onRetry: () =>
                  context.read<PlaylistBloc>().add(const PlaylistRefreshRequested()),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  void _showCreateBottomSheet(BuildContext context) {
    final bloc = context.read<PlaylistBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CreatePlaylistBottomSheet(
        onConfirm: (name, description, isPublic) {
          bloc.add(PlaylistCreateRequested(
            name: name,
            description: description,
            isPublic: isPublic,
          ));
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.spotifyGreen),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.negativeRed, size: 48),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: const TextStyle(color: AppColors.silver),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.base),
          TextButton(
            key: const Key('playlistList_retryButton'),
            onPressed: onRetry,
            child: const Text(
              'Thử lại',
              style: TextStyle(color: AppColors.spotifyGreen),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentView extends StatelessWidget {
  final List<Playlist> playlists;

  const _ContentView({required this.playlists});

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) {
      return const _EmptyView();
    }

    return RefreshIndicator(
      color: AppColors.spotifyGreen,
      backgroundColor: AppColors.darkSurface,
      onRefresh: () async =>
          context.read<PlaylistBloc>().add(const PlaylistRefreshRequested()),
      child: ListView.separated(
        key: const Key('playlistList_listView'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          AppSpacing.sm,
          AppSpacing.base,
          AppSpacing.xxxl,
        ),
        itemCount: playlists.length,
        separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return Dismissible(
            key: Key('playlistList_item_${playlist.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: AppSpacing.base),
              color: AppColors.negativeRed,
              child: const Icon(Icons.delete_outline, color: AppColors.white),
            ),
            confirmDismiss: (_) => _confirmDelete(context, playlist.name),
            onDismissed: (_) => context
                .read<PlaylistBloc>()
                .add(PlaylistDeleteRequested(playlist.id)),
            child: PlaylistCardWidget(
              key: Key('playlistList_card_$index'),
              playlist: playlist,
              onTap: () => context.push('/playlists/${playlist.id}'),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.darkSurface,
            title: const Text(
              'Xóa playlist',
              style: TextStyle(color: AppColors.white),
            ),
            content: Text(
              'Bạn có chắc muốn xóa "$name"?',
              style: const TextStyle(color: AppColors.silver),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(
                  'Hủy',
                  style: TextStyle(color: AppColors.silver),
                ),
              ),
              TextButton(
                key: const Key('playlistList_deleteConfirmButton'),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Xóa',
                  style: TextStyle(color: AppColors.negativeRed),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.queue_music, color: AppColors.silver, size: 64),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Chưa có playlist nào',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Nhấn + để tạo playlist đầu tiên',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.silver,
                ),
          ),
        ],
      ),
    );
  }
}
