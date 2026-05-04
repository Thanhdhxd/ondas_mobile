import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/library/presentation/bloc/library_bloc.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/create_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/delete_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_library_playlists_usecase.dart';

class MockGetLibraryPlaylistsUseCase extends Mock
    implements GetLibraryPlaylistsUseCase {}

class MockCreatePlaylistUseCase extends Mock implements CreatePlaylistUseCase {}

class MockDeletePlaylistUseCase extends Mock implements DeletePlaylistUseCase {}

class FakeCreatePlaylistParams extends Fake implements CreatePlaylistParams {}

const tPlaylist1 = PlaylistSummary(
  id: 'pl-1',
  name: 'Playlist 1',
  totalSongs: 2,
  containsSong: false,
);

const tPlaylist2 = PlaylistSummary(
  id: 'pl-2',
  name: 'Playlist 2',
  totalSongs: 0,
  containsSong: false,
);

const tNewPlaylist = PlaylistSummary(
  id: 'pl-new',
  name: 'New Playlist',
  totalSongs: 0,
  containsSong: false,
);

void main() {
  late LibraryBloc bloc;
  late MockGetLibraryPlaylistsUseCase mockGetPlaylists;
  late MockCreatePlaylistUseCase mockCreatePlaylist;
  late MockDeletePlaylistUseCase mockDeletePlaylist;

  setUpAll(() {
    registerFallbackValue(FakeCreatePlaylistParams());
  });

  setUp(() {
    mockGetPlaylists = MockGetLibraryPlaylistsUseCase();
    mockCreatePlaylist = MockCreatePlaylistUseCase();
    mockDeletePlaylist = MockDeletePlaylistUseCase();
    bloc = LibraryBloc(
      getLibraryPlaylistsUseCase: mockGetPlaylists,
      createPlaylistUseCase: mockCreatePlaylist,
      deletePlaylistUseCase: mockDeletePlaylist,
    );
  });

  tearDown(() => bloc.close());

  group('LibraryBloc — LibraryStarted', () {
    blocTest<LibraryBloc, LibraryState>(
      'emits [LibraryLoading, LibraryLoaded] when playlists are fetched',
      build: () {
        when(() => mockGetPlaylists())
            .thenAnswer((_) async => [tPlaylist1, tPlaylist2]);
        return bloc;
      },
      act: (b) => b.add(const LibraryStarted()),
      expect: () => [
        const LibraryLoading(),
        const LibraryLoaded(playlists: [tPlaylist1, tPlaylist2]),
      ],
    );

    blocTest<LibraryBloc, LibraryState>(
      'emits [LibraryLoading, LibraryLoaded(empty)] when no playlists',
      build: () {
        when(() => mockGetPlaylists()).thenAnswer((_) async => []);
        return bloc;
      },
      act: (b) => b.add(const LibraryStarted()),
      expect: () => [
        const LibraryLoading(),
        const LibraryLoaded(playlists: []),
      ],
    );

    blocTest<LibraryBloc, LibraryState>(
      'emits [LibraryLoading, LibraryError] when fetch throws',
      build: () {
        when(() => mockGetPlaylists()).thenThrow(Exception('Network error'));
        return bloc;
      },
      act: (b) => b.add(const LibraryStarted()),
      expect: () => [
        const LibraryLoading(),
        isA<LibraryError>(),
      ],
    );
  });

  group('LibraryBloc — LibraryPlaylistCreateRequested', () {
    blocTest<LibraryBloc, LibraryState>(
      'adds new playlist to front of list on success',
      seed: () =>
          const LibraryLoaded(playlists: [tPlaylist1, tPlaylist2]),
      build: () {
        when(() => mockCreatePlaylist(any()))
            .thenAnswer((_) async => tNewPlaylist);
        return bloc;
      },
      act: (b) =>
          b.add(const LibraryPlaylistCreateRequested('New Playlist')),
      expect: () => [
        const LibraryLoaded(
            playlists: [tPlaylist1, tPlaylist2], isCreating: true),
        const LibraryLoaded(
            playlists: [tNewPlaylist, tPlaylist1, tPlaylist2]),
      ],
    );

    blocTest<LibraryBloc, LibraryState>(
      'reverts isCreating flag when create fails',
      seed: () =>
          const LibraryLoaded(playlists: [tPlaylist1]),
      build: () {
        when(() => mockCreatePlaylist(any()))
            .thenThrow(Exception('Server error'));
        return bloc;
      },
      act: (b) =>
          b.add(const LibraryPlaylistCreateRequested('Bad Playlist')),
      expect: () => [
        const LibraryLoaded(playlists: [tPlaylist1], isCreating: true),
        const LibraryLoaded(playlists: [tPlaylist1], isCreating: false),
      ],
    );
  });

  group('LibraryBloc — LibraryPlaylistDeleteRequested', () {
    blocTest<LibraryBloc, LibraryState>(
      'removes playlist optimistically and calls delete',
      seed: () =>
          const LibraryLoaded(playlists: [tPlaylist1, tPlaylist2]),
      build: () {
        when(() => mockDeletePlaylist('pl-1'))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (b) =>
          b.add(const LibraryPlaylistDeleteRequested('pl-1')),
      expect: () => [
        const LibraryLoaded(playlists: [tPlaylist2]),
      ],
      verify: (_) =>
          verify(() => mockDeletePlaylist('pl-1')).called(1),
    );

    blocTest<LibraryBloc, LibraryState>(
      'reverts list when delete fails',
      seed: () =>
          const LibraryLoaded(playlists: [tPlaylist1, tPlaylist2]),
      build: () {
        when(() => mockDeletePlaylist('pl-1'))
            .thenThrow(Exception('Forbidden'));
        return bloc;
      },
      act: (b) =>
          b.add(const LibraryPlaylistDeleteRequested('pl-1')),
      expect: () => [
        const LibraryLoaded(playlists: [tPlaylist2]),
        const LibraryLoaded(playlists: [tPlaylist1, tPlaylist2]),
      ],
    );
  });
}
