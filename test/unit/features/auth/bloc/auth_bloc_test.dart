import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/auth/domain/entities/user.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class FakeLoginParams extends Fake implements LoginParams {}

class FakeRegisterParams extends Fake implements RegisterParams {}

void main() {
  late AuthBloc bloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;

  const tUser = User(
    id: '1',
    email: 'test@example.com',
    fullName: 'Test User',
  );

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeRegisterParams());
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    bloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
    );
  });

  tearDown(() => bloc.close());

  group('AuthBloc — LoginSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when login succeeds',
      build: () {
        when(() => mockLoginUseCase(any()))
            .thenAnswer((_) async => const Right(tUser));
        return bloc;
      },
      act: (b) => b.add(
        const LoginSubmitted(email: 'test@example.com', password: '123456'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthSuccess(user: tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when credentials are invalid',
      build: () {
        when(() => mockLoginUseCase(any()))
            .thenAnswer((_) async => const Left(UnauthorizedFailure()));
        return bloc;
      },
      act: (b) => b.add(
        const LoginSubmitted(email: 'test@example.com', password: 'wrong'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailure(message: 'Unauthorized'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when network error occurs',
      build: () {
        when(() => mockLoginUseCase(any())).thenAnswer(
          (_) async => const Left(NetworkFailure(message: 'No connection')),
        );
        return bloc;
      },
      act: (b) => b.add(
        const LoginSubmitted(email: 'test@example.com', password: '123456'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailure(message: 'No connection'),
      ],
    );
  });

  group('AuthBloc — RegisterSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when registration succeeds',
      build: () {
        when(() => mockRegisterUseCase(any()))
            .thenAnswer((_) async => const Right(tUser));
        return bloc;
      },
      act: (b) => b.add(
        const RegisterSubmitted(
          fullName: 'Test User',
          email: 'test@example.com',
          password: '123456',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthSuccess(user: tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when email already exists',
      build: () {
        when(() => mockRegisterUseCase(any())).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'Email already in use', statusCode: 409),
          ),
        );
        return bloc;
      },
      act: (b) => b.add(
        const RegisterSubmitted(
          fullName: 'Test User',
          email: 'taken@example.com',
          password: '123456',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailure(message: 'Email already in use'),
      ],
    );
  });
}
