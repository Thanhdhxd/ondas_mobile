abstract class UpdatePlaylistUseCase {
  Future<void> call(UpdatePlaylistParams params);
}

class UpdatePlaylistParams {
  final String id;
  final String name;
  const UpdatePlaylistParams({required this.id, required this.name});
}
