import 'package:ondas_mobile/features/player/domain/entities/song.dart';

abstract class PlaySongUseCase {
  Future<void> call({required List<Song> songs, required int index});
}

class PlaySongParams {
  final List<Song> songs;
  final int index;

  const PlaySongParams({required this.songs, required this.index});
}
