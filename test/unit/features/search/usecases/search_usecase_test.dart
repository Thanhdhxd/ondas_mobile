import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/home/domain/entities/album_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/artist_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_result.dart';
import 'package:ondas_mobile/features/search/domain/repositories/search_repository.dart';
import 'package:ondas_mobile/features/search/domain/usecases/search_usecase.dart';
import 'package:ondas_mobile/features/search/domain/usecases/search_usecase_impl.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late SearchUseCase useCase;
  late MockSearchRepository mockRepository;

  final tResult = SearchResult(
    query: 'son tung',
    page: 0,
    size: 10,
    totalSongs: 1,
    totalArtists: 1,
    totalAlbums: 1,
    songs: [
      SongSummary(
        id: 'song-1',
        title: 'Lạc Trôi',
        slug: 'lac-troi',
        durationSeconds: 240,
        audioUrl: 'https://example.com/audio.mp3',
        playCount: 5000,
        active: true,
        artists: const [ArtistRef(id: 'a1', name: 'Sơn Tùng M-TP')],
        genres: const [GenreRef(id: 1, name: 'V-Pop')],
      ),
    ],
    artists: const [
      ArtistSummary(id: 'a1', name: 'Sơn Tùng M-TP', slug: 'son-tung-m-tp'),
    ],
    albums: const [
      AlbumSummary(
        id: 'alb-1',
        title: 'M-TP',
        slug: 'm-tp',
        totalTracks: 10,
        artistIds: ['a1'],
      ),
    ],
  );

  setUp(() {
    mockRepository = MockSearchRepository();
    useCase = SearchUseCaseImpl(mockRepository);
  });

  group('SearchUseCase', () {
    test('should return SearchResult when repository call succeeds', () async {
      when(() => mockRepository.search(
            query: any(named: 'query'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          )).thenAnswer((_) async => Right(tResult));

      final result = await useCase(
        const SearchParams(query: 'son tung'),
      );

      expect(result, Right(tResult));
      verify(() => mockRepository.search(
            query: 'son tung',
            page: 0,
            size: 10,
          )).called(1);
    });

    test('should return ServerFailure when repository call fails', () async {
      when(() => mockRepository.search(
            query: any(named: 'query'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          )).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Server error')),
      );

      final result = await useCase(
        const SearchParams(query: 'son tung'),
      );

      expect(result, const Left(ServerFailure(message: 'Server error')));
    });

    test('should return UnauthorizedFailure when not authenticated', () async {
      when(() => mockRepository.search(
            query: any(named: 'query'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          )).thenAnswer(
        (_) async => const Left(UnauthorizedFailure()),
      );

      final result = await useCase(
        const SearchParams(query: 'son tung'),
      );

      expect(result, const Left(UnauthorizedFailure()));
    });

    test('should forward custom page and size params to repository', () async {
      when(() => mockRepository.search(
            query: any(named: 'query'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          )).thenAnswer((_) async => Right(tResult));

      await useCase(const SearchParams(query: 'test', page: 2, size: 5));

      verify(() => mockRepository.search(query: 'test', page: 2, size: 5))
          .called(1);
    });
  });
}
