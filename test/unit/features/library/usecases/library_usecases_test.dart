import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_detail.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/delete_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/delete_playlist_usecase_impl.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_library_playlists_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_library_playlists_usecase_impl.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_playlist_detail_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_playlist_detail_usecase_impl.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/reorder_playlist_songs_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/reorder_playlist_songs_usecase_impl.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/update_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/update_playlist_usecase_impl.dart';

class MockPlaylistRepository extends Mock implements PlaylistRepository {}

const tSummary = PlaylistSummary(
  id: 'playlist-1',
  name: 'My Playlist',
  totalSongs: 3,
  containsSong: false,
);

const tDetail = PlaylistDetail(
  id: 'playlist-1',
  name: 'My Playlist',
  totalSongs: 0,
  songs: [],
);

void main() {
  late MockPlaylistRepository mockRepository;

  setUp(() {
    mockRepository = MockPlaylistRepository();
  });

  group('GetLibraryPlaylistsUseCase', () {
    late GetLibraryPlaylistsUseCase useCase;

    setUp(() => useCase = GetLibraryPlaylistsUseCaseImpl(mockRepository));

    test('should return list of PlaylistSummary', () async {
      when(() => mockRepository.getLibraryPlaylists())
          .thenAnswer((_) async => [tSummary]);

      final result = await useCase();

      expect(result, [tSummary]);
      verify(() => mockRepository.getLibraryPlaylists()).called(1);
    });

    test('should propagate exception when repository throws', () async {
      when(() => mockRepository.getLibraryPlaylists())
          .thenThrow(Exception('Network error'));

      expect(() => useCase(), throwsException);
    });
  });

  group('GetPlaylistDetailUseCase', () {
    late GetPlaylistDetailUseCase useCase;

    setUp(() => useCase = GetPlaylistDetailUseCaseImpl(mockRepository));

    test('should return PlaylistDetail for given id', () async {
      when(() => mockRepository.getPlaylistDetail('playlist-1'))
          .thenAnswer((_) async => tDetail);

      final result = await useCase('playlist-1');

      expect(result, tDetail);
      verify(() => mockRepository.getPlaylistDetail('playlist-1')).called(1);
    });

    test('should propagate exception when repository throws', () async {
      when(() => mockRepository.getPlaylistDetail(any()))
          .thenThrow(Exception('Not found'));

      expect(() => useCase('playlist-1'), throwsException);
    });
  });

  group('UpdatePlaylistUseCase', () {
    late UpdatePlaylistUseCase useCase;

    setUp(() => useCase = UpdatePlaylistUseCaseImpl(mockRepository));

    test('should call repository updatePlaylist with correct params', () async {
      when(() => mockRepository.updatePlaylist(
            id: 'playlist-1',
            name: 'New Name',
          )).thenAnswer((_) async {});

      await useCase(
          const UpdatePlaylistParams(id: 'playlist-1', name: 'New Name'));

      verify(() => mockRepository.updatePlaylist(
            id: 'playlist-1',
            name: 'New Name',
          )).called(1);
    });

    test('should propagate exception when repository throws', () async {
      when(() => mockRepository.updatePlaylist(
            id: any(named: 'id'),
            name: any(named: 'name'),
          )).thenThrow(Exception('Server error'));

      expect(
        () => useCase(
            const UpdatePlaylistParams(id: 'playlist-1', name: 'New Name')),
        throwsException,
      );
    });
  });

  group('DeletePlaylistUseCase', () {
    late DeletePlaylistUseCase useCase;

    setUp(() => useCase = DeletePlaylistUseCaseImpl(mockRepository));

    test('should call repository deletePlaylist with correct id', () async {
      when(() => mockRepository.deletePlaylist('playlist-1'))
          .thenAnswer((_) async {});

      await useCase('playlist-1');

      verify(() => mockRepository.deletePlaylist('playlist-1')).called(1);
    });

    test('should propagate exception when repository throws', () async {
      when(() => mockRepository.deletePlaylist(any()))
          .thenThrow(Exception('Forbidden'));

      expect(() => useCase('playlist-1'), throwsException);
    });
  });

  group('ReorderPlaylistSongsUseCase', () {
    late ReorderPlaylistSongsUseCase useCase;

    setUp(() => useCase = ReorderPlaylistSongsUseCaseImpl(mockRepository));

    test('should call repository reorderPlaylistSongs with correct params',
        () async {
      when(() => mockRepository.reorderPlaylistSongs(
            playlistId: 'playlist-1',
            songIds: ['b', 'a', 'c'],
          )).thenAnswer((_) async {});

      await useCase(const ReorderPlaylistSongsParams(
        playlistId: 'playlist-1',
        songIds: ['b', 'a', 'c'],
      ));

      verify(() => mockRepository.reorderPlaylistSongs(
            playlistId: 'playlist-1',
            songIds: ['b', 'a', 'c'],
          )).called(1);
    });

    test('should propagate exception when repository throws', () async {
      when(() => mockRepository.reorderPlaylistSongs(
            playlistId: any(named: 'playlistId'),
            songIds: any(named: 'songIds'),
          )).thenThrow(Exception('Server error'));

      expect(
        () => useCase(const ReorderPlaylistSongsParams(
          playlistId: 'playlist-1',
          songIds: ['a'],
        )),
        throwsException,
      );
    });
  });
}
