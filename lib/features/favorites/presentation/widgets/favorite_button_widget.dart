import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorite_toggle_bloc.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorite_toggle_event.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorite_toggle_state.dart';

/// A heart icon button that shows and toggles the favourite status of [songId].
///
/// Creates its own [FavoriteToggleBloc] and automatically checks the initial
/// status on mount. Re-creates the bloc whenever [songId] changes.
class FavoriteButtonWidget extends StatelessWidget {
  final String songId;
  final double iconSize;
  final Color? activeColor;
  final Color? inactiveColor;

  const FavoriteButtonWidget({
    super.key,
    required this.songId,
    this.iconSize = 28,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(songId),
      create: (_) => sl<FavoriteToggleBloc>()
        ..add(FavoriteStatusCheckRequested(songId)),
      child: _FavoriteButtonView(
        songId: songId,
        iconSize: iconSize,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
      ),
    );
  }
}

class _FavoriteButtonView extends StatelessWidget {
  final String songId;
  final double iconSize;
  final Color? activeColor;
  final Color? inactiveColor;

  const _FavoriteButtonView({
    required this.songId,
    required this.iconSize,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteToggleBloc, FavoriteToggleState>(
      builder: (context, state) {
        final isFavorited = switch (state) {
          FavoriteToggleLoaded(:final isFavorited) => isFavorited,
          FavoriteToggleError(:final previousStatus) => previousStatus,
          _ => false,
        };
        final isLoading = state is FavoriteToggleLoading;

        return IconButton(
          key: const Key('favoriteButton'),
          onPressed: isLoading
              ? null
              : () => context.read<FavoriteToggleBloc>().add(
                    FavoriteToggleRequested(
                      songId: songId,
                      currentStatus: isFavorited,
                    ),
                  ),
          icon: isLoading
              ? SizedBox(
                  width: iconSize * 0.7,
                  height: iconSize * 0.7,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: activeColor ?? Theme.of(context).colorScheme.primary,
                  ),
                )
              : Icon(
                  isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: iconSize,
                  color: isFavorited
                      ? (activeColor ?? Colors.redAccent)
                      : (inactiveColor ?? Colors.white),
                ),
        );
      },
    );
  }
}
