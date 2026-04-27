import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/create_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/delete_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_my_playlists_usecase.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_event.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_state.dart';

class MockGetMyPlaylistsUseCase extends Mock implements GetMyPlaylistsUseCase {}

class MockCreatePlaylistUseCase extends Mock implements CreatePlaylistUseCase {}

class MockDeletePlaylistUseCase extends Mock implements DeletePlaylistUseCase {}

class FakeGetMyPlaylistsParams extends Fake implements GetMyPlaylistsParams {}

class FakeCreatePlaylistParams extends Fake implements CreatePlaylistParams {}

void main() {
  late PlaylistBloc bloc;
  late MockGetMyPlaylistsUseCase mockGetMyPlaylists;
  late MockCreatePlaylistUseCase mockCreatePlaylist;
  late MockDeletePlaylistUseCase mockDeletePlaylist;

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

  final tPageResult = PageResult<Playlist>(
    items: [tPlaylist],
    page: 0,
    size: 20,
    totalElements: 1,
    totalPages: 1,
  );

  setUpAll(() {
    registerFallbackValue(FakeGetMyPlaylistsParams());
    registerFallbackValue(FakeCreatePlaylistParams());
  });

  setUp(() {
    mockGetMyPlaylists = MockGetMyPlaylistsUseCase();
    mockCreatePlaylist = MockCreatePlaylistUseCase();
    mockDeletePlaylist = MockDeletePlaylistUseCase();
    bloc = PlaylistBloc(
      getMyPlaylistsUseCase: mockGetMyPlaylists,
      createPlaylistUseCase: mockCreatePlaylist,
      deletePlaylistUseCase: mockDeletePlaylist,
    );
  });

  tearDown(() => bloc.close());

  group('PlaylistBloc — PlaylistLoadRequested', () {
    blocTest<PlaylistBloc, PlaylistState>(
      'emits [Loading, Loaded] when fetch succeeds',
      build: () {
        when(() => mockGetMyPlaylists(any()))
            .thenAnswer((_) async => Right(tPageResult));
        return bloc;
      },
      act: (b) => b.add(const PlaylistLoadRequested()),
      expect: () => [
        const PlaylistLoading(),
        PlaylistLoaded(playlists: tPageResult.items),
      ],
    );

    blocTest<PlaylistBloc, PlaylistState>(
      'emits [Loading, Failure] when fetch fails',
      build: () {
        when(() => mockGetMyPlaylists(any())).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Server error')));
        return bloc;
      },
      act: (b) => b.add(const PlaylistLoadRequested()),
      expect: () => [
        const PlaylistLoading(),
        const PlaylistFailure(message: 'Server error'),
      ],
    );
  });

  group('PlaylistBloc — PlaylistCreateRequested', () {
    blocTest<PlaylistBloc, PlaylistState>(
      'emits [Loading, OperationSuccess] when create and refetch succeed',
      build: () {
        when(() => mockCreatePlaylist(any()))
            .thenAnswer((_) async => const Right(tPlaylist));
        when(() => mockGetMyPlaylists(any()))
            .thenAnswer((_) async => Right(tPageResult));
        return bloc;
      },
      act: (b) => b.add(const PlaylistCreateRequested(name: 'Test Playlist')),
      expect: () => [
        const PlaylistLoading(),
        PlaylistOperationSuccess(playlists: tPageResult.items),
      ],
    );

    blocTest<PlaylistBloc, PlaylistState>(
      'emits [Loading, Failure] when create fails',
      build: () {
        when(() => mockCreatePlaylist(any())).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Create failed')));
        return bloc;
      },
      act: (b) => b.add(const PlaylistCreateRequested(name: 'Test Playlist')),
      expect: () => [
        const PlaylistLoading(),
        const PlaylistFailure(message: 'Create failed'),
      ],
    );
  });

  group('PlaylistBloc — PlaylistDeleteRequested', () {
    blocTest<PlaylistBloc, PlaylistState>(
      'emits [Loading, OperationSuccess] when delete and refetch succeed',
      build: () {
        when(() => mockDeletePlaylist(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetMyPlaylists(any()))
            .thenAnswer((_) async => Right(tPageResult));
        return bloc;
      },
      act: (b) => b.add(const PlaylistDeleteRequested('p1')),
      expect: () => [
        const PlaylistLoading(),
        PlaylistOperationSuccess(playlists: tPageResult.items),
      ],
    );

    blocTest<PlaylistBloc, PlaylistState>(
      'emits [Loading, Failure] when delete fails',
      build: () {
        when(() => mockDeletePlaylist(any())).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Delete failed')));
        return bloc;
      },
      act: (b) => b.add(const PlaylistDeleteRequested('p1')),
      expect: () => [
        const PlaylistLoading(),
        const PlaylistFailure(message: 'Delete failed'),
      ],
    );
  });
}
