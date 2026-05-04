part of 'library_bloc.dart';

sealed class LibraryEvent {
  const LibraryEvent();
}

final class LibraryStarted extends LibraryEvent {
  const LibraryStarted();
}

final class LibraryRefreshRequested extends LibraryEvent {
  const LibraryRefreshRequested();
}

final class LibraryPlaylistCreateRequested extends LibraryEvent {
  final String name;
  const LibraryPlaylistCreateRequested(this.name);
}

final class LibraryPlaylistDeleteRequested extends LibraryEvent {
  final String playlistId;
  const LibraryPlaylistDeleteRequested(this.playlistId);
}
