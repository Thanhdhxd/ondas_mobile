import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/library/presentation/bloc/playlist_detail_bloc.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_detail.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_song_item.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_playlist_detail_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/remove_song_from_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/reorder_playlist_songs_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/update_playlist_usecase.dart';

class MockGetPlaylistDetailUseCase extends Mock
    implements GetPlaylistDetailUseCase {}

class MockRemoveSongFromPlaylistUseCase extends Mock
    implements RemoveSongFromPlaylistUseCase {}

class MockReorderPlaylistSongsUseCase extends Mock
    implements ReorderPlaylistSongsUseCase {}

class MockUpdatePlaylistUseCase extends Mock implements UpdatePlaylistUseCase {}

class FakeUpdatePlaylistParams extends Fake implements UpdatePlaylistParams {}

class FakeReorderParams extends Fake implements ReorderPlaylistSongsParams {}

const tSong1 = PlaylistSongItem(
  position: 1,
  songId: 'song-a',
  title: 'Song A',
  durationSeconds: 180,
);

const tSong2 = PlaylistSongItem(
  position: 2,
  songId: 'song-b',
  title: 'Song B',
  durationSeconds: 240,
);

const tDetail = PlaylistDetail(
  id: 'pl-1',
  name: 'My Playlist',
  totalSongs: 2,
  songs: [tSong1, tSong2],
);

void main() {
  late PlaylistDetailBloc bloc;
  late MockGetPlaylistDetailUseCase mockGetDetail;
  late MockRemoveSongFromPlaylistUseCase mockRemoveSong;
  late MockReorderPlaylistSongsUseCase mockReorder;
  late MockUpdatePlaylistUseCase mockUpdate;

  setUpAll(() {
    registerFallbackValue(FakeUpdatePlaylistParams());
    registerFallbackValue(FakeReorderParams());
  });

  setUp(() {
    mockGetDetail = MockGetPlaylistDetailUseCase();
    mockRemoveSong = MockRemoveSongFromPlaylistUseCase();
    mockReorder = MockReorderPlaylistSongsUseCase();
    mockUpdate = MockUpdatePlaylistUseCase();
    bloc = PlaylistDetailBloc(
      getPlaylistDetailUseCase: mockGetDetail,
      removeSongFromPlaylistUseCase: mockRemoveSong,
      reorderPlaylistSongsUseCase: mockReorder,
      updatePlaylistUseCase: mockUpdate,
    );
  });

  tearDown(() => bloc.close());

  group('PlaylistDetailBloc — PlaylistDetailStarted', () {
    blocTest<PlaylistDetailBloc, PlaylistDetailState>(
      'emits [Loading, Loaded] when detail is fetched',
      build: () {
        when(() => mockGetDetail('pl-1')).thenAnswer((_) async => tDetail);
        return bloc;
      },
      act: (b) => b.add(const PlaylistDetailStarted('pl-1')),
      expect: () => [
        const PlaylistDetailLoading(),
        const PlaylistDetailLoaded(tDetail),
      ],
    );

    blocTest<PlaylistDetailBloc, PlaylistDetailState>(
      'emits [Loading, Error] when fetch throws',
      build: () {
        when(() => mockGetDetail(any())).thenThrow(Exception('Not found'));
        return bloc;
      },
      act: (b) => b.add(const PlaylistDetailStarted('pl-1')),
      expect: () => [
        const PlaylistDetailLoading(),
        isA<PlaylistDetailError>(),
      ],
    );
  });

  group('PlaylistDetailBloc — PlaylistDetailSongRemoved', () {
    blocTest<PlaylistDetailBloc, PlaylistDetailState>(
      'removes song optimistically and calls use case',
      seed: () => const PlaylistDetailLoaded(tDetail),
      build: () {
        when(() => mockRemoveSong(
              playlistId: 'pl-1',
              songId: 'song-a',
            )).thenAnswer((_) async {});
        return bloc;
      },
      act: (b) => b.add(const PlaylistDetailSongRemoved('song-a')),
      expect: () => [
        isA<PlaylistDetailLoaded>().having(
          (s) => s.detail.songs.map((s) => s.songId).toList(),
          'songs',
          ['song-b'],
        ),
      ],
      verify: (_) => verify(() => mockRemoveSong(
            playlistId: 'pl-1',
            songId: 'song-a',
          )).called(1),
    );

    blocTest<PlaylistDetailBloc, PlaylistDetailState>(
      'reverts songs when remove fails',
      seed: () => const PlaylistDetailLoaded(tDetail),
      build: () {
        when(() => mockRemoveSong(
              playlistId: any(named: 'playlistId'),
              songId: any(named: 'songId'),
            )).thenThrow(Exception('Server error'));
        return bloc;
      },
      act: (b) => b.add(const PlaylistDetailSongRemoved('song-a')),
      expect: () => [
        isA<PlaylistDetailLoaded>().having(
          (s) => s.detail.songs.length,
          'songs count after optimistic remove',
          1,
        ),
        isA<PlaylistDetailLoaded>().having(
          (s) => s.detail.songs.length,
          'songs count after revert',
          2,
        ),
      ],
    );
  });

  group('PlaylistDetailBloc — PlaylistDetailReordered', () {
    blocTest<PlaylistDetailBloc, PlaylistDetailState>(
      'reorders songs optimistically and calls use case',
      seed: () => const PlaylistDetailLoaded(tDetail),
      build: () {
        when(() => mockReorder(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (b) =>
          b.add(const PlaylistDetailReordered(['song-b', 'song-a'])),
      expect: () => [
        isA<PlaylistDetailLoaded>().having(
          (s) => s.detail.songs.map((s) => s.songId).toList(),
          'reordered songs',
          ['song-b', 'song-a'],
        ),
      ],
      verify: (_) => verify(() => mockReorder(any())).called(1),
    );
  });

  group('PlaylistDetailBloc — PlaylistDetailNameUpdated', () {
    blocTest<PlaylistDetailBloc, PlaylistDetailState>(
      'updates name in state on success',
      seed: () => const PlaylistDetailLoaded(tDetail),
      build: () {
        when(() => mockUpdate(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (b) => b.add(const PlaylistDetailNameUpdated('Renamed')),
      expect: () => [
        isA<PlaylistDetailLoaded>().having(
          (s) => s.detail.name,
          'name',
          'Renamed',
        ),
      ],
    );

    blocTest<PlaylistDetailBloc, PlaylistDetailState>(
      'does not change state when update fails',
      seed: () => const PlaylistDetailLoaded(tDetail),
      build: () {
        when(() => mockUpdate(any())).thenThrow(Exception('Server error'));
        return bloc;
      },
      act: (b) => b.add(const PlaylistDetailNameUpdated('Bad Name')),
      expect: () => [],
    );
  });
}
