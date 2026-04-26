import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/forgot_password_usecase_impl.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late ForgotPasswordUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = ForgotPasswordUseCaseImpl(mockRepository);
  });

  group('ForgotPasswordUseCase', () {
    test('should return void when request succeeds', () async {
      when(
        () => mockRepository.forgotPassword(email: any(named: 'email')),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(
        const ForgotPasswordParams(email: 'test@example.com'),
      );

      expect(result, const Right(null));
      verify(
        () => mockRepository.forgotPassword(email: 'test@example.com'),
      ).called(1);
    });

    test('should return ServerFailure when server error occurs', () async {
      when(
        () => mockRepository.forgotPassword(email: any(named: 'email')),
      ).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Server error')),
      );

      final result = await useCase(
        const ForgotPasswordParams(email: 'test@example.com'),
      );

      expect(result, const Left(ServerFailure(message: 'Server error')));
    });

    test('should return NetworkFailure when network error occurs', () async {
      when(
        () => mockRepository.forgotPassword(email: any(named: 'email')),
      ).thenAnswer(
        (_) async => const Left(
          NetworkFailure(message: 'Không thể kết nối máy chủ.'),
        ),
      );

      final result = await useCase(
        const ForgotPasswordParams(email: 'test@example.com'),
      );

      expect(
        result,
        const Left(NetworkFailure(message: 'Không thể kết nối máy chủ.')),
      );
    });
  });
}
