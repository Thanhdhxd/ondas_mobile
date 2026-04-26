import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/change_password_usecase_impl.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late ChangePasswordUseCase useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = ChangePasswordUseCaseImpl(mockRepository);
  });

  group('ChangePasswordUseCase', () {
    test('should return void when password change succeeds', () async {
      when(
        () => mockRepository.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(
        const ChangePasswordParams(
          currentPassword: 'oldpass123',
          newPassword: 'newpass123',
        ),
      );

      expect(result, const Right(null));
      verify(
        () => mockRepository.changePassword(
          currentPassword: 'oldpass123',
          newPassword: 'newpass123',
        ),
      ).called(1);
    });

    test('should return UnauthorizedFailure when current password is wrong', () async {
      when(
        () => mockRepository.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Left(UnauthorizedFailure()));

      final result = await useCase(
        const ChangePasswordParams(
          currentPassword: 'wrongpass',
          newPassword: 'newpass123',
        ),
      );

      expect(result, const Left(UnauthorizedFailure()));
    });

    test('should return ServerFailure when server error occurs', () async {
      when(
        () => mockRepository.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Server error')),
      );

      final result = await useCase(
        const ChangePasswordParams(
          currentPassword: 'oldpass123',
          newPassword: 'newpass123',
        ),
      );

      expect(result, const Left(ServerFailure(message: 'Server error')));
    });
  });
}
