import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/logout_usecase_impl.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUseCaseImpl(mockRepository);
  });

  group('LogoutUseCase', () {
    test('should return void when logout succeeds', () async {
      when(() => mockRepository.logout()).thenAnswer((_) async => const Right(null));

      final result = await useCase();

      expect(result, const Right(null));
      verify(() => mockRepository.logout()).called(1);
    });

    test('should return ServerFailure when logout fails', () async {
      when(() => mockRepository.logout()).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Server error')),
      );

      final result = await useCase();

      expect(result, const Left(ServerFailure(message: 'Server error')));
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(() => mockRepository.logout()).thenAnswer(
        (_) async => const Left(NetworkFailure(message: 'No connection')),
      );

      final result = await useCase();

      expect(result, const Left(NetworkFailure(message: 'No connection')));
    });
  });
}
