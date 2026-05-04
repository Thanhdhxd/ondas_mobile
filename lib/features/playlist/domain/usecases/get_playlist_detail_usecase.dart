import 'package:ondas_mobile/features/playlist/domain/entities/playlist_detail.dart';

abstract class GetPlaylistDetailUseCase {
  Future<PlaylistDetail> call(String playlistId);
}
