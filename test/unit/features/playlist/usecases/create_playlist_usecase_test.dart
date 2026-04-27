import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/create_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/create_playlist_usecase_impl.dart';

class MockPlaylistRepository extends Mock implements PlaylistRepository {}

class FakeCreatePlaylistParams extends Fake implements CreatePlaylistParams {}

void main() {
  late CreatePlaylistUseCase useCase;
  late MockPlaylistRepository mockRepository;

  const tPlaylist = Playlist(
    id: '1',
    userId: 'u1',
    name: 'My Playlist',
    isPublic: false,
    totalSongs: 0,
    createdAt: '2024-01-01',
    updatedAt: '2024-01-01',
    songs: [],
  );

  setUp(() {
    mockRepository = MockPlaylistRepository();
    useCase = CreatePlaylistUseCaseImpl(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(FakeCreatePlaylistParams());
  });

  group('CreatePlaylistUseCase', () {
    const tParams = CreatePlaylistParams(name: 'My Playlist');

    test('should return Playlist on success', () async {
      when(() => mockRepository.createPlaylist(any()))
          .thenAnswer((_) async => const Right(tPlaylist));

      final result = await useCase(tParams);

      expect(result, const Right(tPlaylist));
      verify(() => mockRepository.createPlaylist(tParams)).called(1);
    });

    test('should return ServerFailure when repository fails', () async {
      when(() => mockRepository.createPlaylist(any()))
          .thenAnswer((_) async => Left(ServerFailure(message: 'Server error')));

      final result = await useCase(tParams);

      expect(result.isLeft(), isTrue);
    });
  });
}
