import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_playlist_detail_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/remove_song_from_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_detail_bloc.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_detail_event.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_detail_state.dart';

class MockGetPlaylistDetailUseCase extends Mock
    implements GetPlaylistDetailUseCase {}

class MockRemoveSongFromPlaylistUseCase extends Mock
    implements RemoveSongFromPlaylistUseCase {}

class FakeRemoveSongFromPlaylistParams extends Fake
    implements RemoveSongFromPlaylistParams {}

const tPlaylist = Playlist(
  id: 'p1',
  userId: 'u1',
  name: 'Test Playlist',
  isPublic: false,
  totalSongs: 2,
  createdAt: '2024-01-01',
  updatedAt: '2024-01-01',
  songs: [],
);

const tPlaylistAfterRemove = Playlist(
  id: 'p1',
  userId: 'u1',
  name: 'Test Playlist',
  isPublic: false,
  totalSongs: 1,
  createdAt: '2024-01-01',
  updatedAt: '2024-01-01',
  songs: [],
);

void main() {
  late PlaylistDetailBloc bloc;
  late MockGetPlaylistDetailUseCase mockGetDetail;
  late MockRemoveSongFromPlaylistUseCase mockRemoveSong;

  setUpAll(() {
    registerFallbackValue(FakeRemoveSongFromPlaylistParams());
  });

  setUp(() {
    mockGetDetail = MockGetPlaylistDetailUseCase();
    mockRemoveSong = MockRemoveSongFromPlaylistUseCase();
    bloc = PlaylistDetailBloc(
      getPlaylistDetailUseCase: mockGetDetail,
      removeSongFromPlaylistUseCase: mockRemoveSong,
    );
  });

  tearDown(() => bloc.close());

  group('PlaylistDetailBloc — PlaylistDetailLoadRequested', () {
    blocTest<PlaylistDetailBloc, PlaylistDetailState>(
      'emits [Loading, Loaded] when fetch succeeds',
      build: () {
        when(() => mockGetDetail(any()))
            .thenAnswer((_) async => const Right(tPlaylist));
        return bloc;
      },
      act: (b) => b.add(const PlaylistDetailLoadRequested('p1')),
      expect: () => [
        const PlaylistDetailLoading(),
        const PlaylistDetailLoaded(playlist: tPlaylist),
      ],
    );

    blocTest<PlaylistDetailBloc, PlaylistDetailState>(
      'emits [Loading, Failure] when fetch fails',
      build: () {
        when(() => mockGetDetail(any())).thenAnswer(
            (_) async => Left(NotFoundFailure(message: 'Not found')));
        return bloc;
      },
      act: (b) => b.add(const PlaylistDetailLoadRequested('nonexistent')),
      expect: () => [
        const PlaylistDetailLoading(),
        const PlaylistDetailFailure(message: 'Not found'),
      ],
    );
  });

  group('PlaylistDetailBloc — PlaylistDetailSongRemoveRequested', () {
    blocTest<PlaylistDetailBloc, PlaylistDetailState>(
      'emits [Loading, Loaded, Loaded(updated)] when load then remove succeed',
      build: () {
        when(() => mockGetDetail(any()))
            .thenAnswer((_) async => const Right(tPlaylist));
        when(() => mockRemoveSong(any()))
            .thenAnswer((_) async => const Right(tPlaylistAfterRemove));
        return bloc;
      },
      act: (b) {
        b.add(const PlaylistDetailLoadRequested('p1'));
        b.add(const PlaylistDetailSongRemoveRequested('s1'));
      },
      expect: () => [
        const PlaylistDetailLoading(),
        const PlaylistDetailLoaded(playlist: tPlaylist),
        const PlaylistDetailLoaded(playlist: tPlaylistAfterRemove),
      ],
    );

    blocTest<PlaylistDetailBloc, PlaylistDetailState>(
      'emits [Loading, Loaded, Failure] when load then remove fails',
      build: () {
        when(() => mockGetDetail(any()))
            .thenAnswer((_) async => const Right(tPlaylist));
        when(() => mockRemoveSong(any())).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Remove failed')));
        return bloc;
      },
      act: (b) {
        b.add(const PlaylistDetailLoadRequested('p1'));
        b.add(const PlaylistDetailSongRemoveRequested('s1'));
      },
      expect: () => [
        const PlaylistDetailLoading(),
        const PlaylistDetailLoaded(playlist: tPlaylist),
        const PlaylistDetailFailure(message: 'Remove failed'),
      ],
    );
  });
}
