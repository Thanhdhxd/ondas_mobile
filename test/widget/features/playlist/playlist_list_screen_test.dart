import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_event.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_state.dart';
import 'package:ondas_mobile/features/playlist/presentation/screens/playlist_list_screen.dart';

class MockPlaylistBloc extends MockBloc<PlaylistEvent, PlaylistState>
    implements PlaylistBloc {}

class _FakePlaylistEvent extends Fake implements PlaylistEvent {}

const tPlaylist = Playlist(
  id: 'p1',
  userId: 'u1',
  name: 'Test Playlist',
  isPublic: false,
  totalSongs: 3,
  createdAt: '2024-01-01',
  updatedAt: '2024-01-01',
  songs: [],
);

void main() {
  late MockPlaylistBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(_FakePlaylistEvent());
  });

  setUp(() async {
    mockBloc = MockPlaylistBloc();
    await GetIt.I.reset();
    GetIt.I.registerFactory<PlaylistBloc>(() => mockBloc);
  });

  Widget buildSubject() => MaterialApp(
        home: const PlaylistListScreen(),
      );

  group('PlaylistListScreen', () {
    testWidgets('renders AppBar with create FAB', (tester) async {
      when(() => mockBloc.state).thenReturn(const PlaylistInitial());
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildSubject());

      expect(find.text('Thư viện'), findsOneWidget);
      expect(find.byKey(const Key('playlistList_createFab')), findsOneWidget);
    });

    testWidgets('shows loading indicator when state is PlaylistLoading',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const PlaylistLoading());
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows playlist list when state is PlaylistLoaded',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const PlaylistLoaded(playlists: [tPlaylist]));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byKey(const Key('playlistList_listView')), findsOneWidget);
      expect(find.text('Test Playlist'), findsOneWidget);
    });

    testWidgets('shows retry button when state is PlaylistFailure',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const PlaylistFailure(message: 'Server error'));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byKey(const Key('playlistList_retryButton')), findsOneWidget);
    });

    testWidgets('shows SnackBar when stream emits PlaylistFailure',
        (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([
          const PlaylistLoading(),
          const PlaylistFailure(message: 'Lỗi tải danh sách'),
        ]),
        initialState: const PlaylistInitial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Lỗi tải danh sách'), findsNWidgets(2));
    });

    testWidgets('tapping retry button adds PlaylistLoadRequested event',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const PlaylistFailure(message: 'Error'));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('playlistList_retryButton')));
      await tester.tap(find.byKey(const Key('playlistList_retryButton')));

      verify(() => mockBloc.add(const PlaylistLoadRequested())).called(1);
    });
  });
}
