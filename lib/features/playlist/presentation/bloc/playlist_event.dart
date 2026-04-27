import 'package:equatable/equatable.dart';

abstract class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object?> get props => [];
}

class PlaylistLoadRequested extends PlaylistEvent {
  const PlaylistLoadRequested();
}

class PlaylistRefreshRequested extends PlaylistEvent {
  const PlaylistRefreshRequested();
}

class PlaylistCreateRequested extends PlaylistEvent {
  final String name;
  final String? description;
  final bool isPublic;

  const PlaylistCreateRequested({
    required this.name,
    this.description,
    this.isPublic = false,
  });

  @override
  List<Object?> get props => [name, description, isPublic];
}

class PlaylistDeleteRequested extends PlaylistEvent {
  final String id;

  const PlaylistDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}
