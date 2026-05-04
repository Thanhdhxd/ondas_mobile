import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/home/domain/entities/album_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/artist_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_result.dart';
import 'package:ondas_mobile/features/search/domain/usecases/search_usecase.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_bloc.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_event.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_state.dart';

class MockSearchUseCase extends Mock implements SearchUseCase {}

class _FakeSearchParams extends Fake implements SearchParams {}

void main() {
  late SearchBloc bloc;
  late MockSearchUseCase mockUseCase;

  final tSongs = List.generate(
    3,
    (i) => SongSummary(
      id: 'song-$i',
      title: 'Song $i',
      slug: 'song-$i',
      durationSeconds: 200,
      audioUrl: 'https://example.com/song-$i.mp3',
      playCount: i * 100,
      active: true,
      artists: [ArtistRef(id: 'a$i', name: 'Artist $i')],
      genres: [GenreRef(id: i, name: 'Genre $i')],
    ),
  );

  final tArtists = List.generate(
    2,
    (i) => ArtistSummary(id: 'artist-$i', name: 'Artist $i', slug: 'artist-$i'),
  );

  final tAlbums = List.generate(
    2,
    (i) => AlbumSummary(
      id: 'album-$i',
      title: 'Album $i',
      slug: 'album-$i',
      totalTracks: 5,
      artistIds: ['a$i'],
    ),
  );

  SearchResult _buildResult({int page = 0}) => SearchResult(
        query: 'test',
        page: page,
        size: 10,
        totalSongs: tSongs.length,
        totalArtists: tArtists.length,
        totalAlbums: tAlbums.length,
        songs: tSongs,
        artists: tArtists,
        albums: tAlbums,
      );

  setUpAll(() {
    registerFallbackValue(_FakeSearchParams());
  });

  setUp(() {
    mockUseCase = MockSearchUseCase();
    bloc = SearchBloc(searchUseCase: mockUseCase);
  });

  tearDown(() => bloc.close());

  group('SearchBloc — SearchSubmitted', () {
    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchLoaded] when use case succeeds',
      build: () {
        when(() => mockUseCase(any()))
            .thenAnswer((_) async => Right(_buildResult()));
        return bloc;
      },
      act: (b) => b.add(const SearchSubmitted('test')),
      expect: () => [
        const SearchLoading(),
        isA<SearchLoaded>()
            .having((s) => s.query, 'query', 'test')
            .having((s) => s.songs.length, 'songs length', tSongs.length)
            .having((s) => s.artists.length, 'artists length', tArtists.length)
            .having((s) => s.albums.length, 'albums length', tAlbums.length),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchFailure] when use case returns Failure',
      build: () {
        when(() => mockUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        return bloc;
      },
      act: (b) => b.add(const SearchSubmitted('test')),
      expect: () => [
        const SearchLoading(),
        const SearchFailure(message: 'Server error'),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchInitial] when query is empty after trim',
      build: () => bloc,
      act: (b) => b.add(const SearchSubmitted('   ')),
      expect: () => [const SearchInitial()],
    );
  });

  group('SearchBloc — SearchCleared', () {
    blocTest<SearchBloc, SearchState>(
      'emits [SearchInitial] when SearchCleared is added',
      build: () => bloc,
      seed: () => SearchLoaded(
        query: 'test',
        songs: tSongs,
        artists: tArtists,
        albums: tAlbums,
        totalSongs: tSongs.length,
        totalArtists: tArtists.length,
        totalAlbums: tAlbums.length,
        page: 0,
        hasMore: false,
      ),
      act: (b) => b.add(const SearchCleared()),
      expect: () => [const SearchInitial()],
    );
  });

  group('SearchBloc — SearchLoadMoreRequested', () {
    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoadingMore, SearchLoaded] with merged results on load more',
      build: () {
        when(() => mockUseCase(any()))
            .thenAnswer((_) async => Right(_buildResult(page: 1)));
        return bloc;
      },
      seed: () => SearchLoaded(
        query: 'test',
        songs: tSongs,
        artists: tArtists,
        albums: tAlbums,
        totalSongs: tSongs.length,
        totalArtists: tArtists.length,
        totalAlbums: tAlbums.length,
        page: 0,
        hasMore: true,
      ),
      act: (b) => b.add(const SearchLoadMoreRequested()),
      expect: () => [
        isA<SearchLoadingMore>(),
        isA<SearchLoaded>()
            .having((s) => s.page, 'page', 1)
            .having((s) => s.songs.length, 'songs merged', tSongs.length * 2),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'does nothing when hasMore is false',
      build: () => bloc,
      seed: () => SearchLoaded(
        query: 'test',
        songs: tSongs,
        artists: tArtists,
        albums: tAlbums,
        totalSongs: tSongs.length,
        totalArtists: tArtists.length,
        totalAlbums: tAlbums.length,
        page: 0,
        hasMore: false,
      ),
      act: (b) => b.add(const SearchLoadMoreRequested()),
      expect: () => [],
    );
  });
}
