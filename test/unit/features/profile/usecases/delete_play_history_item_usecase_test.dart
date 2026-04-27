import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/delete_play_history_item_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/delete_play_history_item_usecase_impl.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late DeletePlayHistoryItemUseCase useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = DeletePlayHistoryItemUseCaseImpl(mockRepository);
  });

  group('DeletePlayHistoryItemUseCase', () {
    test('should return Right(null) when repository call succeeds', () async {
      when(
        () => mockRepository.deletePlayHistoryItem(id: 1),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(const DeletePlayHistoryItemParams(id: 1));

      expect(result, const Right(null));
      verify(() => mockRepository.deletePlayHistoryItem(id: 1)).called(1);
    });

    test('should return Failure when item not found', () async {
      when(
        () => mockRepository.deletePlayHistoryItem(id: 99),
      ).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Not found', statusCode: 404)),
      );

      final result = await useCase(const DeletePlayHistoryItemParams(id: 99));

      expect(
        result,
        const Left(ServerFailure(message: 'Not found', statusCode: 404)),
      );
    });

    test('should return UnauthorizedFailure when not logged in', () async {
      when(
        () => mockRepository.deletePlayHistoryItem(id: any(named: 'id')),
      ).thenAnswer((_) async => const Left(UnauthorizedFailure()));

      final result = await useCase(const DeletePlayHistoryItemParams(id: 1));

      expect(result, const Left(UnauthorizedFailure()));
    });
  });
}
