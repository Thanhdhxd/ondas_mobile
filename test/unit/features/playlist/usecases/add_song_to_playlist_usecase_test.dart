import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/add_song_to_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/add_song_to_playlist_usecase_impl.dart';

class MockPlaylistRepository extends Mock implements PlaylistRepository {}

void main() {
  late AddSongToPlaylistUseCase useCase;
  late MockPlaylistRepository mockRepository;

  const tPlaylist = Playlist(
    id: 'p1',
    userId: 'u1',
    name: 'My Playlist',
    isPublic: false,
    totalSongs: 1,
    createdAt: '2024-01-01',
    updatedAt: '2024-01-01',
    songs: [],
  );

  setUp(() {
    mockRepository = MockPlaylistRepository();
    useCase = AddSongToPlaylistUseCaseImpl(mockRepository);
    registerFallbackValue(const AddSongToPlaylistParams(playlistId: 'p1', songId: 's1'));
  });

  group('AddSongToPlaylistUseCase', () {
    const tParams = AddSongToPlaylistParams(playlistId: 'p1', songId: 's1');

    test('should return updated Playlist on success', () async {
      when(() => mockRepository.addSongToPlaylist(any()))
          .thenAnswer((_) async => const Right(tPlaylist));

      final result = await useCase(tParams);

      expect(result, const Right(tPlaylist));
      verify(() => mockRepository.addSongToPlaylist(tParams)).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.addSongToPlaylist(any()))
          .thenAnswer((_) async => Left(ServerFailure(message: 'Server error')));

      final result = await useCase(tParams);

      expect(result.isLeft(), isTrue);
    });
  });
}
