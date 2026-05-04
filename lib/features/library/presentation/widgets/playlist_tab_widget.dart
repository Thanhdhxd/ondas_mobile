import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/features/library/presentation/bloc/library_bloc.dart';
import 'package:ondas_mobile/features/library/presentation/widgets/library_playlist_item_widget.dart';
import 'package:ondas_mobile/features/playlist/presentation/widgets/create_playlist_dialog.dart';

class PlaylistTabWidget extends StatelessWidget {
  const PlaylistTabWidget({super.key});

  Future<void> _onCreatePlaylist(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const CreatePlaylistDialog(),
    );
    if (name != null && name.isNotEmpty && context.mounted) {
      context.read<LibraryBloc>().add(LibraryPlaylistCreateRequested(name));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _CreatePlaylistButton(
                  isLoading:
                      state is LibraryLoaded && state.isCreating,
                  onTap: () => _onCreatePlaylist(context),
                ),
              ),
            ),
            if (state is LibraryLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.spotifyGreen,
                  ),
                ),
              )
            else if (state is LibraryError)
              SliverFillRemaining(
                child: _ErrorView(
                  message: state.message,
                  onRetry: () => context
                      .read<LibraryBloc>()
                      .add(const LibraryRefreshRequested()),
                ),
              )
            else if (state is LibraryLoaded) ...[
              _MyPlaylistsSection(playlists: state.playlists),
              const _SystemPlaylistsSection(),
            ],
          ],
        );
      },
    );
  }
}

class _CreatePlaylistButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _CreatePlaylistButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const Key('libraryScreen_createPlaylistButton'),
      onPressed: isLoading ? null : onTap,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: AppColors.spotifyGreen,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.add_rounded, color: AppColors.spotifyGreen),
      label: const Text(
        'Create New Playlist',
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        side: const BorderSide(color: AppColors.borderGray),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
        minimumSize: const Size(double.infinity, 0),
      ),
    );
  }
}

class _MyPlaylistsSection extends StatelessWidget {
  final List playlists;

  const _MyPlaylistsSection({required this.playlists});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return const _SectionHeader(title: 'My Playlists');
          }
          if (playlists.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No playlists available. Create a new playlist!',
                  style: TextStyle(color: AppColors.silver, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return LibraryPlaylistItemWidget(
            playlist: playlists[index - 1] as dynamic,
          );
        },
        childCount: playlists.isEmpty ? 2 : playlists.length + 1,
      ),
    );
  }
}

class _SystemPlaylistsSection extends StatelessWidget {
  const _SystemPlaylistsSection();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 8, bottom: 32),
        child: _SectionHeader(title: 'System Playlists'),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
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
          const Icon(Icons.error_outline_rounded,
              color: AppColors.negativeRed, size: 48),
          const SizedBox(height: 12),
          Text(
            'Unable to load playlists',
            style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(color: AppColors.spotifyGreen),
            ),
          ),
        ],
      ),
    );
  }
}
