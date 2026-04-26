import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/forgot_password_bloc.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/forgot_password_event.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/forgot_password_state.dart';

class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}

void main() {
  late ForgotPasswordBloc bloc;
  late MockForgotPasswordUseCase mockUseCase;

  setUpAll(() {
    registerFallbackValue(const ForgotPasswordParams(email: ''));
  });

  setUp(() {
    mockUseCase = MockForgotPasswordUseCase();
    bloc = ForgotPasswordBloc(forgotPasswordUseCase: mockUseCase);
  });

  group('ForgotPasswordBloc', () {
    test('initial state is ForgotPasswordInitial', () {
      expect(bloc.state, const ForgotPasswordInitial());
    });

    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits [Loading, Success] when request succeeds',
      build: () {
        when(() => mockUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (b) =>
          b.add(const ForgotPasswordSubmitted(email: 'test@example.com')),
      expect: () => [
        const ForgotPasswordLoading(),
        const ForgotPasswordSuccess(),
      ],
    );

    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits [Loading, Failure] when request fails',
      build: () {
        when(() => mockUseCase(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Đã xảy ra lỗi server')),
        );
        return bloc;
      },
      act: (b) =>
          b.add(const ForgotPasswordSubmitted(email: 'test@example.com')),
      expect: () => [
        const ForgotPasswordLoading(),
        const ForgotPasswordFailure(message: 'Đã xảy ra lỗi server'),
      ],
    );

    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits [Loading, Failure] when network error occurs',
      build: () {
        when(() => mockUseCase(any())).thenAnswer(
          (_) async => const Left(
            NetworkFailure(message: 'Không thể kết nối máy chủ.'),
          ),
        );
        return bloc;
      },
      act: (b) =>
          b.add(const ForgotPasswordSubmitted(email: 'test@example.com')),
      expect: () => [
        const ForgotPasswordLoading(),
        const ForgotPasswordFailure(message: 'Không thể kết nối máy chủ.'),
      ],
    );
  });
}
