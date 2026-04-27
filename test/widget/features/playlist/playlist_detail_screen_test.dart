import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_state.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_detail_bloc.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_detail_event.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_detail_state.dart';
import 'package:ondas_mobile/features/playlist/presentation/screens/playlist_detail_screen.dart';

class MockPlaylistDetailBloc
    extends MockBloc<PlaylistDetailEvent, PlaylistDetailState>
    implements PlaylistDetailBloc {}

class MockPlayerBloc extends MockBloc<PlayerEvent, PlayerState>
    implements PlayerBloc {}

class _FakePlaylistDetailEvent extends Fake implements PlaylistDetailEvent {}

class _FakePauseRequested extends Fake implements PauseRequested {}

const tPlaylist = Playlist(
  id: 'p1',
  userId: 'u1',
  name: 'Test Playlist',
  isPublic: false,
  totalSongs: 0,
  createdAt: '2024-01-01',
  updatedAt: '2024-01-01',
  songs: [],
);

void main() {
  late MockPlaylistDetailBloc mockDetailBloc;
  late MockPlayerBloc mockPlayerBloc;

  setUpAll(() {
    registerFallbackValue(_FakePlaylistDetailEvent());
    registerFallbackValue(_FakePauseRequested());
  });

  setUp(() async {
    mockDetailBloc = MockPlaylistDetailBloc();
    mockPlayerBloc = MockPlayerBloc();
    await GetIt.I.reset();
    GetIt.I.registerFactory<PlaylistDetailBloc>(() => mockDetailBloc);
  });

  Widget buildSubject() => MultiBlocProvider(
        providers: [
          BlocProvider<PlayerBloc>.value(value: mockPlayerBloc),
        ],
        child: const MaterialApp(
          home: PlaylistDetailScreen(playlistId: 'p1'),
        ),
      );

  group('PlaylistDetailScreen', () {
    testWidgets('shows loading indicator when state is PlaylistDetailLoading',
        (tester) async {
      when(() => mockDetailBloc.state).thenReturn(const PlaylistDetailLoading());
      when(() => mockDetailBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockPlayerBloc.state).thenReturn(const PlayerState());
      when(() => mockPlayerBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows retry button when state is PlaylistDetailFailure',
        (tester) async {
      when(() => mockDetailBloc.state)
          .thenReturn(const PlaylistDetailFailure(message: 'Not found'));
      when(() => mockDetailBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockPlayerBloc.state).thenReturn(const PlayerState());
      when(() => mockPlayerBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byKey(const Key('playlistDetail_retryButton')), findsOneWidget);
    });

    testWidgets('shows playlist name when state is PlaylistDetailLoaded',
        (tester) async {
      when(() => mockDetailBloc.state)
          .thenReturn(const PlaylistDetailLoaded(playlist: tPlaylist));
      when(() => mockDetailBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockPlayerBloc.state).thenReturn(const PlayerState());
      when(() => mockPlayerBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Test Playlist'), findsOneWidget);
    });

    testWidgets('tapping retry adds PlaylistDetailRefreshRequested event',
        (tester) async {
      when(() => mockDetailBloc.state)
          .thenReturn(const PlaylistDetailFailure(message: 'Error'));
      when(() => mockDetailBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockPlayerBloc.state).thenReturn(const PlayerState());
      when(() => mockPlayerBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('playlistDetail_retryButton')));
      await tester.tap(find.byKey(const Key('playlistDetail_retryButton')));

      verify(() => mockDetailBloc.add(const PlaylistDetailRefreshRequested()))
          .called(1);
    });
  });
}
