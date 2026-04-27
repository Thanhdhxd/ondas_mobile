import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';

sealed class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

// ── User events ─────────────────────────────────────────────────────────────

class PlaySongRequested extends PlayerEvent {
  final List<Song> songs;
  final int index;

  const PlaySongRequested({required this.songs, required this.index});

  @override
  List<Object?> get props => [songs, index];
}

class PauseRequested extends PlayerEvent {
  const PauseRequested();
}

class ResumeRequested extends PlayerEvent {
  const ResumeRequested();
}

class SeekRequested extends PlayerEvent {
  final Duration position;

  const SeekRequested(this.position);

  @override
  List<Object?> get props => [position];
}

class SkipNextRequested extends PlayerEvent {
  const SkipNextRequested();
}

class SkipPreviousRequested extends PlayerEvent {
  const SkipPreviousRequested();
}

class VolumeChanged extends PlayerEvent {
  final double volume;

  const VolumeChanged(this.volume);

  @override
  List<Object?> get props => [volume];
}

// ── Internal stream events (emitted by BLoC from service streams) ────────────
// Note: These are defined here but prefixed with underscore to signal
// they are internal. They must be in this file to be accessible from player_bloc.dart.

class PlayerStatusUpdated extends PlayerEvent {
  final dynamic status; // PlayerStatus — avoid circular import at top level

  const PlayerStatusUpdated(this.status);

  @override
  List<Object?> get props => [status];
}

class PlayerPositionUpdated extends PlayerEvent {
  final Duration position;

  const PlayerPositionUpdated(this.position);

  @override
  List<Object?> get props => [position];
}

class PlayerDurationUpdated extends PlayerEvent {
  final Duration duration;

  const PlayerDurationUpdated(this.duration);

  @override
  List<Object?> get props => [duration];
}

class PlayerVolumeUpdated extends PlayerEvent {
  final double volume;

  const PlayerVolumeUpdated(this.volume);

  @override
  List<Object?> get props => [volume];
}
