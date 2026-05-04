import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';

abstract class GetLibraryPlaylistsUseCase {
  Future<List<PlaylistSummary>> call();
}
