import 'package:ondas_mobile/features/player/domain/entities/player_status.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';

/// Abstract interface for audio playback.
///
/// This is the **swap point** for future audio_service integration:
/// implement a new [AudioServicePlayerServiceImpl] without touching BLoC or UseCases.
abstract class AudioPlayerService {
  /// Stream of current [PlayerStatus].
  Stream<PlayerStatus> get statusStream;

  /// Stream of current playback position.
  Stream<Duration> get positionStream;

  /// Stream of current song duration.
  Stream<Duration> get durationStream;

  /// Stream of current volume [0.0 - 1.0].
  Stream<double> get volumeStream;

  /// Current queue.
  List<Song> get queue;

  /// Current index in the queue.
  int get currentIndex;

  /// Current song, or null if [PlayerStatus.idle].
  Song? get currentSong;

  /// Load and play a new queue starting at [index].
  Future<void> playSong({required List<Song> songs, required int index});

  /// Pause playback.
  Future<void> pause();

  /// Resume playback.
  Future<void> resume();

  /// Seek to [position].
  Future<void> seek(Duration position);

  /// Skip to next song in queue.
  Future<void> skipNext();

  /// Skip to previous song in queue.
  Future<void> skipPrevious();

  /// Set volume [0.0 - 1.0].
  Future<void> setVolume(double volume);

  /// Release resources.
  Future<void> dispose();
}
