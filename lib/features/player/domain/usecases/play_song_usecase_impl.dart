import 'package:ondas_mobile/features/player/domain/entities/song.dart';
import 'package:ondas_mobile/features/player/domain/services/audio_player_service.dart';
import 'package:ondas_mobile/features/player/domain/usecases/play_song_usecase.dart';

class PlaySongUseCaseImpl implements PlaySongUseCase {
  final AudioPlayerService _service;

  const PlaySongUseCaseImpl(this._service);

  @override
  Future<void> call({required List<Song> songs, required int index}) {
    return _service.playSong(songs: songs, index: index);
  }
}
