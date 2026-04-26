import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/profile_state.dart';

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

class MockChangePasswordUseCase extends Mock implements ChangePasswordUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class FakeUpdateProfileParams extends Fake implements UpdateProfileParams {}

class FakeChangePasswordParams extends Fake implements ChangePasswordParams {}

void main() {
  late ProfileBloc bloc;
  late MockGetProfileUseCase mockGetProfile;
  late MockUpdateProfileUseCase mockUpdateProfile;
  late MockChangePasswordUseCase mockChangePassword;
  late MockLogoutUseCase mockLogout;

  const tProfile = UserProfile(
    id: 'uuid-1',
    email: 'test@example.com',
    displayName: 'Test User',
    role: 'USER',
  );

  setUpAll(() {
    registerFallbackValue(FakeUpdateProfileParams());
    registerFallbackValue(FakeChangePasswordParams());
  });

  setUp(() {
    mockGetProfile = MockGetProfileUseCase();
    mockUpdateProfile = MockUpdateProfileUseCase();
    mockChangePassword = MockChangePasswordUseCase();
    mockLogout = MockLogoutUseCase();
    bloc = ProfileBloc(
      getProfileUseCase: mockGetProfile,
      updateProfileUseCase: mockUpdateProfile,
      changePasswordUseCase: mockChangePassword,
      logoutUseCase: mockLogout,
    );
  });

  tearDown(() => bloc.close());

  group('ProfileBloc — ProfileLoadRequested', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] when getProfile succeeds',
      build: () {
        when(() => mockGetProfile()).thenAnswer((_) async => const Right(tProfile));
        return bloc;
      },
      act: (b) => b.add(const ProfileLoadRequested()),
      expect: () => [const ProfileLoading(), const ProfileLoaded(tProfile)],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileFailure] when getProfile fails',
      build: () {
        when(() => mockGetProfile()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        return bloc;
      },
      act: (b) => b.add(const ProfileLoadRequested()),
      expect: () => [const ProfileLoading(), const ProfileFailure('Server error')],
    );
  });

  group('ProfileBloc — ProfileUpdateRequested', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileUpdateSuccess] when update succeeds',
      build: () {
        when(() => mockUpdateProfile(any())).thenAnswer((_) async => const Right(tProfile));
        return bloc;
      },
      act: (b) => b.add(const ProfileUpdateRequested(displayName: 'New Name')),
      expect: () => [const ProfileLoading(), const ProfileUpdateSuccess(tProfile)],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileFailure] when update fails',
      build: () {
        when(() => mockUpdateProfile(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Update failed')),
        );
        return bloc;
      },
      act: (b) => b.add(const ProfileUpdateRequested(displayName: 'New Name')),
      expect: () => [const ProfileLoading(), const ProfileFailure('Update failed')],
    );
  });

  group('ProfileBloc — ProfileChangePasswordRequested', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfilePasswordChangeSuccess] when change password succeeds',
      build: () {
        when(() => mockChangePassword(any())).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (b) => b.add(
        const ProfileChangePasswordRequested(
          currentPassword: 'old123',
          newPassword: 'new123456',
        ),
      ),
      expect: () => [const ProfileLoading(), const ProfilePasswordChangeSuccess()],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileFailure] when current password is wrong',
      build: () {
        when(() => mockChangePassword(any())).thenAnswer(
          (_) async => const Left(UnauthorizedFailure()),
        );
        return bloc;
      },
      act: (b) => b.add(
        const ProfileChangePasswordRequested(
          currentPassword: 'wrong',
          newPassword: 'new123456',
        ),
      ),
      expect: () => [const ProfileLoading(), const ProfileFailure('Unauthorized')],
    );
  });

  group('ProfileBloc — ProfileLogoutRequested', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLogoutSuccess] when logout succeeds',
      build: () {
        when(() => mockLogout()).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (b) => b.add(const ProfileLogoutRequested()),
      expect: () => [const ProfileLoading(), const ProfileLogoutSuccess()],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileFailure] when logout fails',
      build: () {
        when(() => mockLogout()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Logout failed')),
        );
        return bloc;
      },
      act: (b) => b.add(const ProfileLogoutRequested()),
      expect: () => [const ProfileLoading(), const ProfileFailure('Logout failed')],
    );
  });
}
