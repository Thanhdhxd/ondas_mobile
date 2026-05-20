import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';

abstract class GetSystemPlaylistsUseCase {
  Future<List<PlaylistSummary>> call();
}
