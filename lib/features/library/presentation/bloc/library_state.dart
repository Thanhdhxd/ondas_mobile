part of 'library_bloc.dart';

sealed class LibraryState extends Equatable {
  const LibraryState();
}

final class LibraryInitial extends LibraryState {
  const LibraryInitial();
  @override
  List<Object?> get props => [];
}

final class LibraryLoading extends LibraryState {
  const LibraryLoading();
  @override
  List<Object?> get props => [];
}

final class LibraryLoaded extends LibraryState {
  final List<PlaylistSummary> playlists;
  final List<PlaylistSummary> systemPlaylists;
  final bool isCreating;

  const LibraryLoaded({
    required this.playlists,
    this.systemPlaylists = const [],
    this.isCreating = false,
  });

  LibraryLoaded copyWith({
    List<PlaylistSummary>? playlists,
    List<PlaylistSummary>? systemPlaylists,
    bool? isCreating,
  }) {
    return LibraryLoaded(
      playlists: playlists ?? this.playlists,
      systemPlaylists: systemPlaylists ?? this.systemPlaylists,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  @override
  List<Object?> get props => [playlists, systemPlaylists, isCreating];
}

final class LibraryError extends LibraryState {
  final String message;
  const LibraryError(this.message);
  @override
  List<Object?> get props => [message];
}
