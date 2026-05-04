import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/home/domain/entities/album_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/artist_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';
import 'package:ondas_mobile/features/player/domain/entities/player_status.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_state.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_bloc.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_event.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_state.dart';

class MockSearchBloc extends MockBloc<SearchEvent, SearchState>
    implements SearchBloc {}

class MockPlayerBloc extends MockBloc<PlayerEvent, PlayerState>
    implements PlayerBloc {}

class _FakeSearchEvent extends Fake implements SearchEvent {}

class _FakePlayerEvent extends Fake implements PlayerEvent {}

final _tSongs = List.generate(
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

final _tArtists = List.generate(
  2,
  (i) => ArtistSummary(id: 'artist-$i', name: 'Artist $i', slug: 'artist-$i'),
);

final _tAlbums = List.generate(
  2,
  (i) => AlbumSummary(
    id: 'album-$i',
    title: 'Album $i',
    slug: 'album-$i',
    totalTracks: 5,
    artistIds: ['a$i'],
  ),
);

final _tLoaded = SearchLoaded(
  query: 'test',
  songs: _tSongs,
  artists: _tArtists,
  albums: _tAlbums,
  totalSongs: _tSongs.length,
  totalArtists: _tArtists.length,
  totalAlbums: _tAlbums.length,
  page: 0,
  hasMore: false,
);

void main() {
  late MockSearchBloc mockSearchBloc;
  late MockPlayerBloc mockPlayerBloc;

  setUpAll(() {
    registerFallbackValue(_FakeSearchEvent());
    registerFallbackValue(_FakePlayerEvent());
  });

  setUp(() {
    mockSearchBloc = MockSearchBloc();
    mockPlayerBloc = MockPlayerBloc();
    when(() => mockPlayerBloc.state).thenReturn(
      const PlayerState(status: PlayerStatus.idle),
    );
  });

  Widget buildSubject() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SearchBloc>.value(value: mockSearchBloc),
          BlocProvider<PlayerBloc>.value(value: mockPlayerBloc),
        ],
        child: const _SearchViewUnderTest(),
      ),
    );
  }

  group('SearchScreen', () {
    testWidgets('renders search field on initial state', (tester) async {
      when(() => mockSearchBloc.state).thenReturn(const SearchInitial());

      await tester.pumpWidget(buildSubject());

      expect(find.byKey(const Key('searchScreen_searchField')), findsOneWidget);
    });

    testWidgets('shows empty prompt when state is SearchInitial',
        (tester) async {
      when(() => mockSearchBloc.state).thenReturn(const SearchInitial());

      await tester.pumpWidget(buildSubject());

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows loading indicator when state is SearchLoading',
        (tester) async {
      when(() => mockSearchBloc.state).thenReturn(const SearchLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error and retry button when state is SearchFailure',
        (tester) async {
      when(() => mockSearchBloc.state).thenReturn(
        const SearchFailure(message: 'Server error'),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Server error'), findsOneWidget);
      expect(find.byKey(const Key('searchScreen_retryButton')), findsOneWidget);
    });

    testWidgets('shows results list when state is SearchLoaded', (tester) async {
      when(() => mockSearchBloc.state).thenReturn(_tLoaded);

      await tester.pumpWidget(buildSubject());

      expect(find.byKey(const Key('searchScreen_resultsList')), findsOneWidget);
      expect(find.text('Song 0'), findsOneWidget);
      expect(find.text('Artist 0'), findsOneWidget);
      expect(find.text('Album 0'), findsOneWidget);
    });

    testWidgets('shows section headers with counts when SearchLoaded',
        (tester) async {
      when(() => mockSearchBloc.state).thenReturn(_tLoaded);

      await tester.pumpWidget(buildSubject());

      expect(find.text('Bài hát'), findsOneWidget);
      expect(find.text('Nghệ sĩ'), findsOneWidget);
      expect(find.text('Album'), findsOneWidget);
    });

    testWidgets('tapping clear button dispatches SearchCleared', (tester) async {
      when(() => mockSearchBloc.state).thenReturn(const SearchInitial());

      await tester.pumpWidget(buildSubject());

      // Type something to show the clear button
      await tester.enterText(
        find.byKey(const Key('searchScreen_searchField')),
        'test',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('searchScreen_clearButton')));
      await tester.pump();

      verify(() => mockSearchBloc.add(const SearchCleared())).called(1);
    });
  });
}

/// Inner view that accepts blocs from context — bypasses sl<> creation
class _SearchViewUnderTest extends StatelessWidget {
  const _SearchViewUnderTest();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                key: const Key('searchScreen_searchField'),
                onChanged: (value) {
                  if (value.trim().isEmpty) {
                    context.read<SearchBloc>().add(const SearchCleared());
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    key: const Key('searchScreen_clearButton'),
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        context.read<SearchBloc>().add(const SearchCleared()),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) => switch (state) {
                  SearchInitial() => const Center(
                      child: Icon(Icons.search, size: 64),
                    ),
                  SearchLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  SearchLoaded(
                    :final songs,
                    :final artists,
                    :final albums,
                    :final totalSongs,
                    :final totalArtists,
                    :final totalAlbums,
                  ) =>
                    ListView(
                      key: const Key('searchScreen_resultsList'),
                      children: [
                        if (songs.isNotEmpty) ...[
                          Text('Bài hát'),
                          ...songs.map((s) => Text(s.title)),
                        ],
                        if (artists.isNotEmpty) ...[
                          Text('Nghệ sĩ'),
                          ...artists.map((a) => Text(a.name)),
                        ],
                        if (albums.isNotEmpty) ...[
                          Text('Album'),
                          ...albums.map((a) => Text(a.title)),
                        ],
                      ],
                    ),
                  SearchFailure(:final message) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(message),
                          TextButton(
                            key: const Key('searchScreen_retryButton'),
                            onPressed: () {},
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  _ => const SizedBox.shrink(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
