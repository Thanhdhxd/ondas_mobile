import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/reset_password_usecase_impl.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late ResetPasswordUseCase useCase;
  late MockAuthRepository mockRepository;

  const tParams = ResetPasswordParams(
    email: 'test@example.com',
    otp: '123456',
    newPassword: 'newpassword123',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = ResetPasswordUseCaseImpl(mockRepository);
  });

  group('ResetPasswordUseCase', () {
    test('should return void when reset succeeds', () async {
      when(
        () => mockRepository.resetPassword(
          email: any(named: 'email'),
          otp: any(named: 'otp'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(tParams);

      expect(result, const Right(null));
      verify(
        () => mockRepository.resetPassword(
          email: 'test@example.com',
          otp: '123456',
          newPassword: 'newpassword123',
        ),
      ).called(1);
    });

    test('should return ServerFailure when OTP is invalid', () async {
      when(
        () => mockRepository.resetPassword(
          email: any(named: 'email'),
          otp: any(named: 'otp'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'OTP không hợp lệ')),
      );

      final result = await useCase(tParams);

      expect(result, const Left(ServerFailure(message: 'OTP không hợp lệ')));
    });

    test('should return NetworkFailure when network error occurs', () async {
      when(
        () => mockRepository.resetPassword(
          email: any(named: 'email'),
          otp: any(named: 'otp'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer(
        (_) async => const Left(
          NetworkFailure(message: 'Không thể kết nối máy chủ.'),
        ),
      );

      final result = await useCase(tParams);

      expect(
        result,
        const Left(NetworkFailure(message: 'Không thể kết nối máy chủ.')),
      );
    });
  });
}
