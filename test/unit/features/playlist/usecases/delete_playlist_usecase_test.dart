import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/delete_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/delete_playlist_usecase_impl.dart';

class MockPlaylistRepository extends Mock implements PlaylistRepository {}

void main() {
  late DeletePlaylistUseCase useCase;
  late MockPlaylistRepository mockRepository;

  setUp(() {
    mockRepository = MockPlaylistRepository();
    useCase = DeletePlaylistUseCaseImpl(mockRepository);
  });

  group('DeletePlaylistUseCase', () {
    test('should call repository deletePlaylist and return Right(null) on success', () async {
      when(() => mockRepository.deletePlaylist(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase('p1');

      expect(result.isRight(), isTrue);
      verify(() => mockRepository.deletePlaylist('p1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.deletePlaylist(any()))
          .thenAnswer((_) async => Left(ServerFailure(message: 'Server error')));

      final result = await useCase('p1');

      expect(result.isLeft(), isTrue);
    });
  });
}
