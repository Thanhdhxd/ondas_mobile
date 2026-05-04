import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/library/presentation/bloc/library_bloc.dart';
import 'package:ondas_mobile/features/library/presentation/screens/library_screen.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';

class MockLibraryBloc extends MockBloc<LibraryEvent, LibraryState>
    implements LibraryBloc {}

const tPlaylist = PlaylistSummary(
  id: 'pl-1',
  name: 'My Playlist',
  totalSongs: 5,
  containsSong: false,
);

void main() {
  late MockLibraryBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(const LibraryRefreshRequested());
  });

  setUp(() async {
    await GetIt.I.reset();
    mockBloc = MockLibraryBloc();
    GetIt.I.registerFactory<LibraryBloc>(() => mockBloc);
  });

  Widget buildSubject() {
    return const MaterialApp(home: LibraryScreen());
  }

  group('LibraryScreen', () {
    testWidgets('renders Favorite tab and Playlist tab', (tester) async {
      when(() => mockBloc.state).thenReturn(const LibraryLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byKey(const Key('libraryScreen_favoriteTab')), findsOneWidget);
      expect(find.byKey(const Key('libraryScreen_playlistTab')), findsOneWidget);
    });

    testWidgets('shows loading indicator when state is LibraryLoading',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const LibraryLoading());

      await tester.pumpWidget(buildSubject());
      // Switch to Playlist tab
      await tester.tap(find.byKey(const Key('libraryScreen_playlistTab')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets(
        'shows create playlist button and playlist list when state is LibraryLoaded',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const LibraryLoaded(playlists: [tPlaylist]));

      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byKey(const Key('libraryScreen_playlistTab')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('libraryScreen_createPlaylistButton')),
        findsOneWidget,
      );
      expect(find.text('My Playlist'), findsOneWidget);
      expect(find.text('5 songs'), findsOneWidget);
    });

    testWidgets('shows empty playlist message when loaded with empty list',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const LibraryLoaded(playlists: []));

      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byKey(const Key('libraryScreen_playlistTab')));
      await tester.pumpAndSettle();

      expect(find.text('No playlists available. Create a new playlist!'),
          findsOneWidget);
    });

    testWidgets('shows retry button when state is LibraryError', (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const LibraryError('Network error'));

      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byKey(const Key('libraryScreen_playlistTab')));
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets(
        'dispatches LibraryRefreshRequested when retry button is tapped',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const LibraryError('Error'));

      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byKey(const Key('libraryScreen_playlistTab')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockBloc.add(const LibraryRefreshRequested())).called(1);
    });

    testWidgets('shows Favorite tab with coming soon message', (tester) async {
      when(() => mockBloc.state).thenReturn(const LibraryLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.text('Feature under development'), findsOneWidget);
    });
  });
}
