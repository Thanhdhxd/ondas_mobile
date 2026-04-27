import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_my_playlists_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_my_playlists_usecase_impl.dart';

class MockPlaylistRepository extends Mock implements PlaylistRepository {}

void main() {
  late GetMyPlaylistsUseCase useCase;
  late MockPlaylistRepository mockRepository;

  final tPageResult = PageResult<Playlist>(
    items: const [],
    page: 0,
    size: 20,
    totalElements: 0,
    totalPages: 0,
  );

  setUp(() {
    mockRepository = MockPlaylistRepository();
    useCase = GetMyPlaylistsUseCaseImpl(mockRepository);
  });

  group('GetMyPlaylistsUseCase', () {
    test('should return PageResult<Playlist> on success', () async {
      when(
        () => mockRepository.getMyPlaylists(page: any(named: 'page'), size: any(named: 'size')),
      ).thenAnswer((_) async => Right(tPageResult));

      final result = await useCase(const GetMyPlaylistsParams());

      expect(result, Right(tPageResult));
      verify(() => mockRepository.getMyPlaylists(page: 0, size: 20)).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(
        () => mockRepository.getMyPlaylists(page: any(named: 'page'), size: any(named: 'size')),
      ).thenAnswer((_) async => Left(ServerFailure(message: 'Server error')));

      final result = await useCase(const GetMyPlaylistsParams());

      expect(result, Left(ServerFailure(message: 'Server error')));
    });
  });
}
