import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/profile/domain/entities/play_history_item.dart';
import 'package:ondas_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/get_play_history_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/get_play_history_usecase_impl.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late GetPlayHistoryUseCase useCase;
  late MockProfileRepository mockRepository;

  final tSong = PlayHistorySong(
    id: 'song-uuid',
    title: 'Test Song',
    durationSeconds: 210,
    audioUrl: 'http://host/audio.mp3',
  );

  final tItem = PlayHistoryItem(
    id: 1,
    song: tSong,
    playedAt: DateTime(2026, 4, 27, 10),
    source: 'home',
  );

  final tPage = PageResult<PlayHistoryItem>(
    items: [tItem],
    page: 0,
    size: 20,
    totalElements: 1,
    totalPages: 1,
  );

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetPlayHistoryUseCaseImpl(mockRepository);
  });

  group('GetPlayHistoryUseCase', () {
    test('should return PageResult when repository call succeeds', () async {
      when(
        () => mockRepository.getPlayHistory(page: 0, size: 20),
      ).thenAnswer((_) async => Right(tPage));

      final result = await useCase(const GetPlayHistoryParams(page: 0, size: 20));

      expect(result, Right(tPage));
      verify(() => mockRepository.getPlayHistory(page: 0, size: 20)).called(1);
    });

    test('should return Failure when repository returns failure', () async {
      when(
        () => mockRepository.getPlayHistory(page: 0, size: 20),
      ).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Server error')),
      );

      final result = await useCase(const GetPlayHistoryParams(page: 0, size: 20));

      expect(result, const Left(ServerFailure(message: 'Server error')));
    });

    test('should return UnauthorizedFailure when token is invalid', () async {
      when(
        () => mockRepository.getPlayHistory(page: any(named: 'page'), size: any(named: 'size')),
      ).thenAnswer((_) async => const Left(UnauthorizedFailure()));

      final result = await useCase(const GetPlayHistoryParams(page: 0, size: 20));

      expect(result, const Left(UnauthorizedFailure()));
    });
  });
}
