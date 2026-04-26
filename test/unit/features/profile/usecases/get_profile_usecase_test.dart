import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:ondas_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/get_profile_usecase_impl.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late GetProfileUseCase useCase;
  late MockProfileRepository mockRepository;

  const tProfile = UserProfile(
    id: 'uuid-1',
    email: 'test@example.com',
    displayName: 'Test User',
    role: 'USER',
  );

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetProfileUseCaseImpl(mockRepository);
  });

  group('GetProfileUseCase', () {
    test('should return UserProfile when call succeeds', () async {
      when(() => mockRepository.getProfile()).thenAnswer((_) async => const Right(tProfile));

      final result = await useCase();

      expect(result, const Right(tProfile));
      verify(() => mockRepository.getProfile()).called(1);
    });

    test('should return UnauthorizedFailure when token is invalid', () async {
      when(() => mockRepository.getProfile()).thenAnswer(
        (_) async => const Left(UnauthorizedFailure()),
      );

      final result = await useCase();

      expect(result, const Left(UnauthorizedFailure()));
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(() => mockRepository.getProfile()).thenAnswer(
        (_) async => const Left(NetworkFailure(message: 'No connection')),
      );

      final result = await useCase();

      expect(result, const Left(NetworkFailure(message: 'No connection')));
    });
  });
}
