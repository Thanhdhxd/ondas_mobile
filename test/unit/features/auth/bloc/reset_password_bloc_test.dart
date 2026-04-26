import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/reset_password_bloc.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/reset_password_event.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/reset_password_state.dart';

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

void main() {
  late ResetPasswordBloc bloc;
  late MockResetPasswordUseCase mockUseCase;

  setUpAll(() {
    registerFallbackValue(
      const ResetPasswordParams(
        email: '',
        otp: '',
        newPassword: '',
      ),
    );
  });

  setUp(() {
    mockUseCase = MockResetPasswordUseCase();
    bloc = ResetPasswordBloc(resetPasswordUseCase: mockUseCase);
  });

  const tEvent = ResetPasswordSubmitted(
    email: 'test@example.com',
    otp: '123456',
    newPassword: 'newpassword123',
  );

  group('ResetPasswordBloc', () {
    test('initial state is ResetPasswordInitial', () {
      expect(bloc.state, const ResetPasswordInitial());
    });

    blocTest<ResetPasswordBloc, ResetPasswordState>(
      'emits [Loading, Success] when reset succeeds',
      build: () {
        when(() => mockUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (b) => b.add(tEvent),
      expect: () => [
        const ResetPasswordLoading(),
        const ResetPasswordSuccess(),
      ],
    );

    blocTest<ResetPasswordBloc, ResetPasswordState>(
      'emits [Loading, Failure] when OTP is invalid',
      build: () {
        when(() => mockUseCase(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'OTP không hợp lệ')),
        );
        return bloc;
      },
      act: (b) => b.add(tEvent),
      expect: () => [
        const ResetPasswordLoading(),
        const ResetPasswordFailure(message: 'OTP không hợp lệ'),
      ],
    );

    blocTest<ResetPasswordBloc, ResetPasswordState>(
      'emits [Loading, Failure] when network error occurs',
      build: () {
        when(() => mockUseCase(any())).thenAnswer(
          (_) async => const Left(
            NetworkFailure(message: 'Không thể kết nối máy chủ.'),
          ),
        );
        return bloc;
      },
      act: (b) => b.add(tEvent),
      expect: () => [
        const ResetPasswordLoading(),
        const ResetPasswordFailure(message: 'Không thể kết nối máy chủ.'),
      ],
    );
  });
}
