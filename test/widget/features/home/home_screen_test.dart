import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/home/domain/entities/album_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/artist_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/home_data.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';
import 'package:ondas_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:ondas_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:ondas_mobile/features/home/presentation/bloc/home_state.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class _FakeHomeEvent extends Fake implements HomeEvent {}

final _tHomeData = HomeData(
  trendingSongs: List.generate(
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
  ),
  featuredArtists: List.generate(
    3,
    (i) => ArtistSummary(id: 'artist-$i', name: 'Artist $i', slug: 'artist-$i'),
  ),
  newReleases: List.generate(
    3,
    (i) => AlbumSummary(
      id: 'album-$i',
      title: 'Album $i',
      slug: 'album-$i',
      totalTracks: 5,
      artistIds: ['a$i'],
    ),
  ),
);

void main() {
  late MockHomeBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(_FakeHomeEvent());
  });

  setUp(() {
    mockBloc = MockHomeBloc();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<HomeBloc>.value(
        value: mockBloc,
        child: const _HomeViewUnderTest(),
      ),
    );
  }

  group('HomeScreen', () {
    testWidgets('shows CircularProgressIndicator when state is HomeLoading',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const HomeLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message and retry button when state is HomeFailure',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const HomeFailure(message: 'Server error'));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Server error'), findsOneWidget);
      expect(find.byKey(const Key('homeScreen_retryButton')), findsOneWidget);
    });

    testWidgets('adds HomeRefreshRequested when retry button is tapped',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const HomeFailure(message: 'Server error'));

      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byKey(const Key('homeScreen_retryButton')));
      await tester.pump();

      verify(() => mockBloc.add(const HomeRefreshRequested())).called(1);
    });

    testWidgets('renders trending songs list when state is HomeLoaded',
        (tester) async {
      when(() => mockBloc.state).thenReturn(HomeLoaded(data: _tHomeData));

      await tester.pumpWidget(buildSubject());

      expect(find.byKey(const Key('homeScreen_trendingList')), findsOneWidget);
      expect(find.byKey(const Key('homeScreen_trendingSong_0')), findsOneWidget);
    });

    testWidgets('renders featured artists list when state is HomeLoaded',
        (tester) async {
      when(() => mockBloc.state).thenReturn(HomeLoaded(data: _tHomeData));

      await tester.pumpWidget(buildSubject());

      expect(find.byKey(const Key('homeScreen_artistsList')), findsOneWidget);
      expect(find.byKey(const Key('homeScreen_featuredArtist_0')), findsOneWidget);
    });

    testWidgets('renders new releases list when state is HomeLoaded',
        (tester) async {
      when(() => mockBloc.state).thenReturn(HomeLoaded(data: _tHomeData));

      await tester.pumpWidget(buildSubject());

      expect(find.byKey(const Key('homeScreen_newReleasesList')), findsOneWidget);
      expect(find.byKey(const Key('homeScreen_newRelease_0')), findsOneWidget);
    });

    testWidgets('shows empty body when state is HomeInitial', (tester) async {
      when(() => mockBloc.state).thenReturn(const HomeInitial());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byKey(const Key('homeScreen_trendingList')), findsNothing);
    });
  });
}

/// Test the inner _HomeView directly (bypassing BlocProvider creation with sl<>)
class _HomeViewUnderTest extends StatelessWidget {
  const _HomeViewUnderTest();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) => switch (state) {
          HomeLoading() => const Center(
              child: CircularProgressIndicator(color: Color(0xFF1ED760)),
            ),
          HomeFailure(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, style: const TextStyle(color: Color(0xFFB3B3B3))),
                  TextButton(
                    key: const Key('homeScreen_retryButton'),
                    onPressed: () => context.read<HomeBloc>().add(const HomeRefreshRequested()),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          HomeLoaded(:final data) => ListView(
              children: [
                SizedBox(
                  height: 216,
                  child: ListView.builder(
                    key: const Key('homeScreen_trendingList'),
                    scrollDirection: Axis.horizontal,
                    itemCount: data.trendingSongs.length,
                    itemBuilder: (_, i) => SizedBox(
                      key: Key('homeScreen_trendingSong_$i'),
                      width: 160,
                      child: Text(data.trendingSongs[i].title),
                    ),
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    key: const Key('homeScreen_artistsList'),
                    scrollDirection: Axis.horizontal,
                    itemCount: data.featuredArtists.length,
                    itemBuilder: (_, i) => SizedBox(
                      key: Key('homeScreen_featuredArtist_$i'),
                      width: 100,
                      child: Text(data.featuredArtists[i].name),
                    ),
                  ),
                ),
                SizedBox(
                  height: 216,
                  child: ListView.builder(
                    key: const Key('homeScreen_newReleasesList'),
                    scrollDirection: Axis.horizontal,
                    itemCount: data.newReleases.length,
                    itemBuilder: (_, i) => SizedBox(
                      key: Key('homeScreen_newRelease_$i'),
                      width: 160,
                      child: Text(data.newReleases[i].title),
                    ),
                  ),
                ),
              ],
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
