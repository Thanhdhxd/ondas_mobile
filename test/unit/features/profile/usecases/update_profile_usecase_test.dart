import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:ondas_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/update_profile_usecase_impl.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late UpdateProfileUseCase useCase;
  late MockProfileRepository mockRepository;

  const tProfile = UserProfile(
    id: 'uuid-1',
    email: 'test@example.com',
    displayName: 'Updated Name',
    role: 'USER',
  );

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = UpdateProfileUseCaseImpl(mockRepository);
  });

  group('UpdateProfileUseCase', () {
    test('should return updated UserProfile when call succeeds', () async {
      when(
        () => mockRepository.updateProfile(
          displayName: any(named: 'displayName'),
        ),
      ).thenAnswer((_) async => const Right(tProfile));

      final result = await useCase(
        const UpdateProfileParams(displayName: 'Updated Name'),
      );

      expect(result, const Right(tProfile));
      verify(
        () => mockRepository.updateProfile(displayName: 'Updated Name'),
      ).called(1);
    });

    test('should return ServerFailure when update fails', () async {
      when(
        () => mockRepository.updateProfile(
          displayName: any(named: 'displayName'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      final result = await useCase(const UpdateProfileParams(displayName: 'Name'));

      expect(result, const Left(ServerFailure(message: 'Server error')));
    });
  });
}
