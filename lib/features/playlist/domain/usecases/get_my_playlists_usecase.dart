import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';

abstract class GetMyPlaylistsUseCase {
  Future<List<PlaylistSummary>> call({required String songId});
}
