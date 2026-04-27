import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/player/domain/entities/player_status.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';

class PlayerState extends Equatable {
  final Song? currentSong;
  final List<Song> queue;
  final int currentIndex;
  final PlayerStatus status;
  final Duration position;
  final Duration duration;
  final double volume;
  final RepeatMode repeatMode;
  final String? errorMessage;

  const PlayerState({
    this.currentSong,
    this.queue = const [],
    this.currentIndex = 0,
    this.status = PlayerStatus.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.repeatMode = RepeatMode.off,
    this.errorMessage,
  });

  bool get hasNext => currentIndex < queue.length - 1;
  bool get hasPrevious => currentIndex > 0 || position.inSeconds > 3;

  PlayerState copyWith({
    Song? currentSong,
    List<Song>? queue,
    int? currentIndex,
    PlayerStatus? status,
    Duration? position,
    Duration? duration,
    double? volume,
    RepeatMode? repeatMode,
    String? errorMessage,
    bool clearCurrentSong = false,
    bool clearError = false,
  }) {
    return PlayerState(
      currentSong: clearCurrentSong ? null : (currentSong ?? this.currentSong),
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      repeatMode: repeatMode ?? this.repeatMode,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        currentSong,
        queue,
        currentIndex,
        status,
        position,
        duration,
        volume,
        repeatMode,
        errorMessage,
      ];
}
