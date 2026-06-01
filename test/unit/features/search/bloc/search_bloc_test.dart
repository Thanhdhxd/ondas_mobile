import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/home/domain/entities/album_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/artist_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_result.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_suggestion.dart';
import 'package:ondas_mobile/features/search/domain/usecases/clear_search_history_usecase.dart';
import 'package:ondas_mobile/features/search/domain/usecases/get_search_suggestions_usecase.dart';
import 'package:ondas_mobile/features/search/domain/usecases/search_usecase.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_bloc.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_event.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_state.dart';
import 'package:ondas_mobile/features/songs/domain/usecases/get_songs_usecase.dart';
import 'package:ondas_mobile/features/tags/domain/usecases/get_tags_usecase.dart';

class MockSearchUseCase extends Mock implements SearchUseCase {}

class MockGetSearchSuggestionsUseCase extends Mock
    implements GetSearchSuggestionsUseCase {}

class MockClearSearchHistoryUseCase extends Mock
    implements ClearSearchHistoryUseCase {}

class MockGetTagsUseCase extends Mock implements GetTagsUseCase {}

class MockGetSongsUseCase extends Mock implements GetSongsUseCase {}

class _FakeSearchParams extends Fake implements SearchParams {}

void main() {
  late SearchBloc bloc;
  late MockSearchUseCase mockUseCase;
  late MockGetSearchSuggestionsUseCase mockGetSuggestionsUseCase;
  late MockClearSearchHistoryUseCase mockClearHistoryUseCase;
  late MockGetTagsUseCase mockGetTagsUseCase;
  late MockGetSongsUseCase mockGetSongsUseCase;

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

  const tSuggestion = SearchSuggestion(
    recentSearches: [],
    trendingSearches: [],
    trendingSongs: [],
    genres: [],
    tags: [],
  );

  SearchResult buildResult({int page = 0}) => SearchResult(
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
    mockGetSuggestionsUseCase = MockGetSearchSuggestionsUseCase();
    mockClearHistoryUseCase = MockClearSearchHistoryUseCase();
    mockGetTagsUseCase = MockGetTagsUseCase();
    mockGetSongsUseCase = MockGetSongsUseCase();

    // Default stub: suggestions always succeed
    when(() => mockGetSuggestionsUseCase())
        .thenAnswer((_) async => const Right(tSuggestion));
    when(() => mockGetTagsUseCase()).thenAnswer((_) async => const Right([]));

    bloc = SearchBloc(
      searchUseCase: mockUseCase,
      getSuggestionsUseCase: mockGetSuggestionsUseCase,
      clearHistoryUseCase: mockClearHistoryUseCase,
      getTagsUseCase: mockGetTagsUseCase,
      getSongsUseCase: mockGetSongsUseCase,
    );
  });

  tearDown(() => bloc.close());

  group('SearchBloc — SearchSubmitted', () {
    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchLoaded] when use case succeeds',
      build: () {
        when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(buildResult()));
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
      'restores suggestions when query is empty after trim',
      build: () => bloc,
      act: (b) => b.add(const SearchSubmitted('   ')),
      // When _cachedSuggestion is null the bloc dispatches SuggestionsRequested
      // internally, which emits SearchSuggestionsLoading then SearchSuggestionsLoaded.
      expect: () => [
        const SearchSuggestionsLoading(),
        isA<SearchSuggestionsLoaded>()
            .having((s) => s.suggestion, 'suggestion', tSuggestion),
      ],
    );
  });

  group('SearchBloc — SearchCleared', () {
    blocTest<SearchBloc, SearchState>(
      'restores suggestions when SearchCleared is added',
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
      // _cachedSuggestion is null → bloc dispatches SuggestionsRequested internally.
      expect: () => [
        const SearchSuggestionsLoading(),
        isA<SearchSuggestionsLoaded>()
            .having((s) => s.suggestion, 'suggestion', tSuggestion),
      ],
    );
  });

  group('SearchBloc — SearchLoadMoreRequested', () {
    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoadingMore, SearchLoaded] with merged results on load more',
      build: () {
        when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(buildResult(page: 1)));
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
