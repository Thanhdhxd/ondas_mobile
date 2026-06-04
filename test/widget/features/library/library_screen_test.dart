import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/localization/language_cubit.dart';
import 'package:ondas_mobile/core/network/network_status.dart';
import 'package:ondas_mobile/core/network/network_status_cubit.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:ondas_mobile/features/library/presentation/bloc/library_bloc.dart';
import 'package:ondas_mobile/features/library/presentation/screens/library_screen.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';

class MockLibraryBloc extends MockBloc<LibraryEvent, LibraryState>
    implements LibraryBloc {}
class MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState>
  implements FavoritesBloc {}
class MockLanguageCubit extends MockCubit<String> implements LanguageCubit {}
class MockNetworkStatusCubit extends MockCubit<NetworkStatus>
  implements NetworkStatusCubit {}

const tPlaylist = PlaylistSummary(
  id: 'pl-1',
  name: 'My Playlist',
  totalSongs: 5,
  containsSong: false,
);

void main() {
  late MockLibraryBloc mockBloc;
  late MockFavoritesBloc mockFavoritesBloc;
  late MockLanguageCubit mockLanguageCubit;
  late MockNetworkStatusCubit mockNetworkStatusCubit;

  setUpAll(() {
    registerFallbackValue(const LibraryRefreshRequested());
  });

  setUp(() async {
    await GetIt.I.reset();
    mockBloc = MockLibraryBloc();
    mockFavoritesBloc = MockFavoritesBloc();
    when(() => mockFavoritesBloc.state).thenReturn(
      const FavoritesListLoaded(
        items: [],
        hasMore: false,
        currentPage: 0,
      ),
    );
    whenListen(
      mockFavoritesBloc,
      Stream<FavoritesState>.value(
        const FavoritesListLoaded(
          items: [],
          hasMore: false,
          currentPage: 0,
        ),
      ),
      initialState: const FavoritesListLoaded(
        items: [],
        hasMore: false,
        currentPage: 0,
      ),
    );
    mockLanguageCubit = MockLanguageCubit();
    when(() => mockLanguageCubit.state).thenReturn('en');
    whenListen(mockLanguageCubit, Stream<String>.value('en'), initialState: 'en');
    mockNetworkStatusCubit = MockNetworkStatusCubit();
    when(() => mockNetworkStatusCubit.state).thenReturn(NetworkStatus.online);
    whenListen(
      mockNetworkStatusCubit,
      Stream<NetworkStatus>.value(NetworkStatus.online),
      initialState: NetworkStatus.online,
    );
    GetIt.I.registerFactory<LibraryBloc>(() => mockBloc);
    GetIt.I.registerFactory<FavoritesBloc>(() => mockFavoritesBloc);
  });

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LanguageCubit>.value(value: mockLanguageCubit),
        BlocProvider<NetworkStatusCubit>.value(value: mockNetworkStatusCubit),
      ],
      child: const MaterialApp(home: LibraryScreen()),
    );
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

    testWidgets('shows Favorite tab empty state', (tester) async {
      when(() => mockBloc.state).thenReturn(const LibraryLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.text('No favorite songs yet'), findsOneWidget);
      expect(find.text('Tap the ♥ icon to add songs'), findsOneWidget);
    });
  });
}
