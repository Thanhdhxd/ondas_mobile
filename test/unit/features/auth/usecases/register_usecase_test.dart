import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/auth/domain/entities/user.dart';
import 'package:ondas_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/register_usecase_impl.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepository;

  const tUser = User(
    id: '1',
    email: 'test@example.com',
    fullName: 'Test User',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCaseImpl(mockRepository);
  });

  group('RegisterUseCase', () {
    test('should return User when registration succeeds', () async {
      when(
        () => mockRepository.register(
          fullName: any(named: 'fullName'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Right(tUser));

      final result = await useCase(
        const RegisterParams(
          fullName: 'Test User',
          email: 'test@example.com',
          password: '123456',
        ),
      );

      expect(result, const Right(tUser));
      verify(
        () => mockRepository.register(
          fullName: 'Test User',
          email: 'test@example.com',
          password: '123456',
        ),
      ).called(1);
    });

    test('should return ServerFailure when email already exists', () async {
      when(
        () => mockRepository.register(
          fullName: any(named: 'fullName'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Email already in use', statusCode: 409)),
      );

      final result = await useCase(
        const RegisterParams(
          fullName: 'Test User',
          email: 'taken@example.com',
          password: '123456',
        ),
      );

      expect(
        result,
        const Left(ServerFailure(message: 'Email already in use', statusCode: 409)),
      );
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(
        () => mockRepository.register(
          fullName: any(named: 'fullName'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Left(NetworkFailure(message: 'No connection')),
      );

      final result = await useCase(
        const RegisterParams(
          fullName: 'Test User',
          email: 'test@example.com',
          password: '123456',
        ),
      );

      expect(result, const Left(NetworkFailure(message: 'No connection')));
    });
  });
}
