import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:ondas_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/upload_avatar_usecase_impl.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late UploadAvatarUseCase useCase;
  late MockProfileRepository mockRepository;

  const tProfile = UserProfile(
    id: 'uuid-1',
    email: 'test@example.com',
    displayName: 'Test User',
    avatarUrl: 'http://192.168.1.1:9000/ondas-images/avatar.png',
    role: 'USER',
  );

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = UploadAvatarUseCaseImpl(mockRepository);
  });

  group('UploadAvatarUseCase', () {
    test('should return updated UserProfile when upload succeeds', () async {
      when(
        () => mockRepository.uploadAvatar(filePath: any(named: 'filePath')),
      ).thenAnswer((_) async => const Right(tProfile));

      final result = await useCase(
        const UploadAvatarParams(filePath: '/data/user/0/avatar.jpg'),
      );

      expect(result, const Right(tProfile));
      verify(
        () => mockRepository.uploadAvatar(filePath: '/data/user/0/avatar.jpg'),
      ).called(1);
    });

    test('should return ServerFailure when upload fails', () async {
      when(
        () => mockRepository.uploadAvatar(filePath: any(named: 'filePath')),
      ).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Upload failed')),
      );

      final result = await useCase(
        const UploadAvatarParams(filePath: '/data/user/0/avatar.jpg'),
      );

      expect(result, const Left(ServerFailure(message: 'Upload failed')));
    });

    test('should return UnauthorizedFailure when token is invalid', () async {
      when(
        () => mockRepository.uploadAvatar(filePath: any(named: 'filePath')),
      ).thenAnswer((_) async => const Left(UnauthorizedFailure()));

      final result = await useCase(
        const UploadAvatarParams(filePath: '/data/user/0/avatar.jpg'),
      );

      expect(result, const Left(UnauthorizedFailure()));
    });
  });
}
