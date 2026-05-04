part of 'save_to_playlist_bloc.dart';

sealed class SaveToPlaylistState {
  const SaveToPlaylistState();
}

final class SaveToPlaylistInitial extends SaveToPlaylistState {
  const SaveToPlaylistInitial();
}

final class SaveToPlaylistLoading extends SaveToPlaylistState {
  const SaveToPlaylistLoading();
}

final class SaveToPlaylistReady extends SaveToPlaylistState {
  final List<PlaylistSummary> playlists;

  /// True while a create-playlist API call is in flight.
  final bool isCreating;

  const SaveToPlaylistReady({
    required this.playlists,
    this.isCreating = false,
  });

  SaveToPlaylistReady copyWith({
    List<PlaylistSummary>? playlists,
    bool? isCreating,
  }) {
    return SaveToPlaylistReady(
      playlists: playlists ?? this.playlists,
      isCreating: isCreating ?? this.isCreating,
    );
  }
}

final class SaveToPlaylistError extends SaveToPlaylistState {
  final String message;

  const SaveToPlaylistError(this.message);
}
