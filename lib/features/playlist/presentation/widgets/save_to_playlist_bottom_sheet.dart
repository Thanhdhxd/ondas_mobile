import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/save_to_playlist_bloc.dart';
import 'package:ondas_mobile/features/playlist/presentation/widgets/create_playlist_dialog.dart';
import 'package:ondas_mobile/features/playlist/presentation/widgets/playlist_list_tile_widget.dart';

class SaveToPlaylistBottomSheet extends StatelessWidget {
  final String songId;
  final String? coverUrl;

  const SaveToPlaylistBottomSheet({
    super.key,
    required this.songId,
    this.coverUrl,
  });

  static Future<void> show(
    BuildContext context, {
    required String songId,
    String? coverUrl,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SaveToPlaylistBottomSheet(
        songId: songId,
        coverUrl: coverUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SaveToPlaylistBloc>()
        ..add(SaveToPlaylistStarted(songId: songId, coverUrl: coverUrl)),
      child: _BottomSheetContent(songId: songId, coverUrl: coverUrl),
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  final String songId;
  final String? coverUrl;

  const _BottomSheetContent({required this.songId, this.coverUrl});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.65),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DragHandle(),
          _Header(),
          Flexible(child: _PlaylistList(songId: songId)),
          const Divider(color: AppColors.borderGray, height: 1),
          _NewPlaylistButton(songId: songId, coverUrl: coverUrl),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.sm),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.lightBorder,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Text(
            'Lưu vào playlist',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.silver, size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _PlaylistList extends StatelessWidget {
  final String songId;

  const _PlaylistList({required this.songId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaveToPlaylistBloc, SaveToPlaylistState>(
      builder: (context, state) {
        return switch (state) {
          SaveToPlaylistLoading() => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.spotifyGreen),
              ),
            ),
          SaveToPlaylistError(:final message) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.negativeRed, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: const TextStyle(color: AppColors.silver, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          SaveToPlaylistReady(:final playlists, :final isCreating) =>
            isCreating
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.spotifyGreen,
                      ),
                    ),
                  )
                : playlists.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'Bạn chưa có playlist nào.',
                            style: TextStyle(
                              color: AppColors.silver,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: playlists.length,
                        itemBuilder: (context, index) {
                          final playlist = playlists[index];
                          return PlaylistListTileWidget(
                            key: ValueKey(playlist.id),
                            playlist: playlist,
                            onToggle: () => context.read<SaveToPlaylistBloc>().add(
                                  PlaylistToggled(
                                    playlistId: playlist.id,
                                    songId: songId,
                                    currentlyContains: playlist.containsSong,
                                  ),
                                ),
                          );
                        },
                      ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}

class _NewPlaylistButton extends StatelessWidget {
  final String songId;
  final String? coverUrl;

  const _NewPlaylistButton({required this.songId, this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('saveToPlaylist_newPlaylistButton'),
      onTap: () async {
        final name = await showDialog<String>(
          context: context,
          builder: (_) => const CreatePlaylistDialog(),
        );
        if (name != null && name.isNotEmpty && context.mounted) {
          context.read<SaveToPlaylistBloc>().add(
                CreatePlaylistRequested(
                  name: name,
                  songId: songId,
                  coverUrl: coverUrl,
                ),
              );
        }
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.add_rounded, color: AppColors.white, size: 28),
            SizedBox(width: 16),
            Text(
              'Tạo playlist mới',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
