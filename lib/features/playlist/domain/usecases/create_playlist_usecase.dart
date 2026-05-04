import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';

abstract class CreatePlaylistUseCase {
  Future<PlaylistSummary> call(CreatePlaylistParams params);
}

class CreatePlaylistParams {
  final String name;
  final String? coverImageUrl;

  const CreatePlaylistParams({required this.name, this.coverImageUrl});
}
