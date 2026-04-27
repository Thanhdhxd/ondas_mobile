import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/clear_play_history_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/clear_play_history_usecase_impl.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late ClearPlayHistoryUseCase useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = ClearPlayHistoryUseCaseImpl(mockRepository);
  });

  group('ClearPlayHistoryUseCase', () {
    test('should return Right(null) when repository call succeeds', () async {
      when(
        () => mockRepository.clearPlayHistory(),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase();

      expect(result, const Right(null));
      verify(() => mockRepository.clearPlayHistory()).called(1);
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(
        () => mockRepository.clearPlayHistory(),
      ).thenAnswer(
        (_) async => const Left(NetworkFailure(message: 'No connection')),
      );

      final result = await useCase();

      expect(result, const Left(NetworkFailure(message: 'No connection')));
    });

    test('should return UnauthorizedFailure when not logged in', () async {
      when(
        () => mockRepository.clearPlayHistory(),
      ).thenAnswer((_) async => const Left(UnauthorizedFailure()));

      final result = await useCase();

      expect(result, const Left(UnauthorizedFailure()));
    });
  });
}
