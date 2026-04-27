import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/home/domain/entities/album_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/artist_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/home_data.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';
import 'package:ondas_mobile/features/home/domain/repositories/home_repository.dart';
import 'package:ondas_mobile/features/home/domain/usecases/get_home_data_usecase.dart';
import 'package:ondas_mobile/features/home/domain/usecases/get_home_data_usecase_impl.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late GetHomeDataUseCase useCase;
  late MockHomeRepository mockRepository;

  final tHomeData = HomeData(
    trendingSongs: [
      SongSummary(
        id: 'song-1',
        title: 'Test Song',
        slug: 'test-song',
        durationSeconds: 210,
        audioUrl: 'https://example.com/audio.mp3',
        playCount: 1000,
        active: true,
        artists: const [ArtistRef(id: 'a1', name: 'Test Artist')],
        genres: const [GenreRef(id: 1, name: 'Pop')],
      ),
    ],
    featuredArtists: const [
      ArtistSummary(id: 'artist-1', name: 'Test Artist', slug: 'test-artist'),
    ],
    newReleases: const [
      AlbumSummary(
        id: 'album-1',
        title: 'Test Album',
        slug: 'test-album',
        totalTracks: 10,
        artistIds: ['a1'],
      ),
    ],
  );

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetHomeDataUseCaseImpl(mockRepository);
  });

  group('GetHomeDataUseCase', () {
    test('should return HomeData when repository call succeeds', () async {
      when(() => mockRepository.getHomeData())
          .thenAnswer((_) async => Right(tHomeData));

      final result = await useCase();

      expect(result, Right(tHomeData));
      verify(() => mockRepository.getHomeData()).called(1);
    });

    test('should return ServerFailure when repository call fails', () async {
      when(() => mockRepository.getHomeData()).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Server error')),
      );

      final result = await useCase();

      expect(result, const Left(ServerFailure(message: 'Server error')));
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(() => mockRepository.getHomeData()).thenAnswer(
        (_) async => const Left(NetworkFailure(message: 'No connection')),
      );

      final result = await useCase();

      expect(result, const Left(NetworkFailure(message: 'No connection')));
    });
  });
}
