import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/library/presentation/bloc/playlist_detail_bloc.dart';
import 'package:ondas_mobile/features/library/presentation/screens/playlist_detail_screen.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_state.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_detail.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_song_item.dart';

class MockPlaylistDetailBloc
    extends MockBloc<PlaylistDetailEvent, PlaylistDetailState>
    implements PlaylistDetailBloc {}

class MockPlayerBloc extends MockBloc<PlayerEvent, PlayerState>
    implements PlayerBloc {}

class _FakePlayerEvent extends Fake implements PlayerEvent {}

const tSong1 = PlaylistSongItem(
  position: 1,
  songId: 'song-a',
  title: 'Song A',
  durationSeconds: 185,
  audioUrl: 'https://example.com/song-a.mp3',
  artistNames: ['Artist A'],
);

const tSong2 = PlaylistSongItem(
  position: 2,
  songId: 'song-b',
  title: 'Song B',
  durationSeconds: 220,
  audioUrl: 'https://example.com/song-b.mp3',
  artistNames: ['Artist B'],
);

const tDetail = PlaylistDetail(
  id: 'pl-1',
  name: 'My Playlist',
  totalSongs: 2,
  songs: [tSong1, tSong2],
);

void main() {
  late MockPlaylistDetailBloc mockBloc;
  late MockPlayerBloc mockPlayerBloc;

  setUpAll(() {
    registerFallbackValue(const PlaylistDetailSongRemoved(''));
    registerFallbackValue(_FakePlayerEvent());
  });

  setUp(() {
    mockBloc = MockPlaylistDetailBloc();
    mockPlayerBloc = MockPlayerBloc();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<PlaylistDetailBloc>.value(value: mockBloc),
          BlocProvider<PlayerBloc>.value(value: mockPlayerBloc),
        ],
        child: const PlaylistDetailScreen(initialName: 'My Playlist'),
      ),
    );
  }

  group('PlaylistDetailScreen', () {
    testWidgets('shows loading indicator when state is Loading', (tester) async {
      when(() => mockBloc.state).thenReturn(const PlaylistDetailLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows song titles when state is Loaded', (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const PlaylistDetailLoaded(tDetail));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Song A'), findsOneWidget);
      expect(find.text('Song B'), findsOneWidget);
    });

    testWidgets('shows edit button in AppBar when loaded', (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const PlaylistDetailLoaded(tDetail));

      await tester.pumpWidget(buildSubject());

      expect(
        find.byKey(const Key('playlistDetailScreen_editButton')),
        findsOneWidget,
      );
    });

    testWidgets('shows empty state when playlist has no songs', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const PlaylistDetailLoaded(
          PlaylistDetail(id: 'pl-1', name: 'Empty', totalSongs: 0, songs: []),
        ),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Playlist này chưa có bài hát'), findsOneWidget);
    });

    testWidgets('shows error view when state is Error', (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const PlaylistDetailError('Network error'));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Không thể tải playlist'), findsOneWidget);
    });

    testWidgets('dispatches PlaylistDetailSongRemoved when remove icon tapped',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const PlaylistDetailLoaded(tDetail));

      await tester.pumpWidget(buildSubject());

      // Tap the first remove button
      final removeIcons = find.byIcon(Icons.remove_circle_outline_rounded);
      expect(removeIcons, findsNWidgets(2));

      await tester.tap(removeIcons.first);
      await tester.pump();

      verify(() => mockBloc.add(const PlaylistDetailSongRemoved('song-a')))
          .called(1);
    });

    testWidgets('shows initialName in AppBar before detail loads',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const PlaylistDetailLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.text('My Playlist'), findsOneWidget);
    });

    testWidgets(
        'dispatches PlaySongRequested to PlayerBloc when song tile tapped',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const PlaylistDetailLoaded(tDetail));

      await tester.pumpWidget(buildSubject());

      await tester.tap(find.text('Song A'));
      await tester.pump();

      verify(
        () => mockPlayerBloc.add(
          PlaySongRequested(
            songs: const [
              Song(
                id: 'song-a',
                title: 'Song A',
                artistNames: ['Artist A'],
                coverUrl: null,
                audioUrl: 'https://example.com/song-a.mp3',
                durationSeconds: 185,
              ),
              Song(
                id: 'song-b',
                title: 'Song B',
                artistNames: ['Artist B'],
                coverUrl: null,
                audioUrl: 'https://example.com/song-b.mp3',
                durationSeconds: 220,
              ),
            ],
            index: 0,
            source: 'playlist',
          ),
        ),
      ).called(1);
    });
  });
}
