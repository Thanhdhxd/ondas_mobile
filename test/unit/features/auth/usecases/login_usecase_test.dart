import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/auth/domain/entities/user.dart';
import 'package:ondas_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/login_usecase_impl.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  const tUser = User(
    id: '1',
    email: 'test@example.com',
    fullName: 'Test User',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCaseImpl(mockRepository);
  });

  group('LoginUseCase', () {
    test('should return User when login succeeds', () async {
      when(
        () => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Right(tUser));

      final result = await useCase(
        const LoginParams(email: 'test@example.com', password: '123456'),
      );

      expect(result, const Right(tUser));
      verify(
        () => mockRepository.login(
          email: 'test@example.com',
          password: '123456',
        ),
      ).called(1);
    });

    test('should return UnauthorizedFailure when credentials are invalid', () async {
      when(
        () => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Left(UnauthorizedFailure()));

      final result = await useCase(
        const LoginParams(email: 'test@example.com', password: 'wrong'),
      );

      expect(result, const Left(UnauthorizedFailure()));
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(
        () => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Left(NetworkFailure(message: 'No connection')),
      );

      final result = await useCase(
        const LoginParams(email: 'test@example.com', password: '123456'),
      );

      expect(result, const Left(NetworkFailure(message: 'No connection')));
    });
  });
}
