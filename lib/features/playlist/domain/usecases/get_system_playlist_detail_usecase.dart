import 'package:ondas_mobile/features/playlist/domain/entities/playlist_detail.dart';

abstract class GetSystemPlaylistDetailUseCase {
  Future<PlaylistDetail> call(String id);
}
