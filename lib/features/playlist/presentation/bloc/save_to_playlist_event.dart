part of 'save_to_playlist_bloc.dart';

sealed class SaveToPlaylistEvent {
  const SaveToPlaylistEvent();
}

/// Load the user's playlists, passing [songId] so each item carries containsSong.
final class SaveToPlaylistStarted extends SaveToPlaylistEvent {
  final String songId;
  final String? coverUrl;

  const SaveToPlaylistStarted({required this.songId, this.coverUrl});
}

/// Toggle a playlist: add if [currentlyContains] is false, remove if true.
final class PlaylistToggled extends SaveToPlaylistEvent {
  final String playlistId;
  final String songId;
  final bool currentlyContains;

  const PlaylistToggled({
    required this.playlistId,
    required this.songId,
    required this.currentlyContains,
  });
}

/// Create a new playlist and immediately add the current song to it.
final class CreatePlaylistRequested extends SaveToPlaylistEvent {
  final String name;
  final String songId;
  final String? coverUrl;

  const CreatePlaylistRequested({
    required this.name,
    required this.songId,
    this.coverUrl,
  });
}
