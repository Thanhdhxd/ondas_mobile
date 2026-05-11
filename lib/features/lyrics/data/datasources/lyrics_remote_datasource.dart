import 'package:ondas_mobile/features/lyrics/data/models/lyrics_model.dart';

abstract class LyricsRemoteDatasource {
  Future<LyricsModel> getLyrics(String songId);
}
