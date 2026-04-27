import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_playlist_detail_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_playlist_detail_usecase_impl.dart';

class MockPlaylistRepository extends Mock implements PlaylistRepository {}

void main() {
  late GetPlaylistDetailUseCase useCase;
  late MockPlaylistRepository mockRepository;

  const tPlaylist = Playlist(
    id: 'p1',
    userId: 'u1',
    name: 'Test Playlist',
    isPublic: true,
    totalSongs: 3,
    createdAt: '2024-01-01',
    updatedAt: '2024-01-01',
    songs: [],
  );

  setUp(() {
    mockRepository = MockPlaylistRepository();
    useCase = GetPlaylistDetailUseCaseImpl(mockRepository);
  });

  group('GetPlaylistDetailUseCase', () {
    test('should return Playlist on success', () async {
      when(() => mockRepository.getPlaylistDetail(any()))
          .thenAnswer((_) async => const Right(tPlaylist));

      final result = await useCase('p1');

      expect(result, const Right(tPlaylist));
      verify(() => mockRepository.getPlaylistDetail('p1')).called(1);
    });

    test('should return NotFoundFailure when playlist does not exist', () async {
      when(() => mockRepository.getPlaylistDetail(any()))
          .thenAnswer((_) async => Left(NotFoundFailure(message: 'Not found')));

      final result = await useCase('nonexistent');

      expect(result.isLeft(), isTrue);
    });
  });
}
