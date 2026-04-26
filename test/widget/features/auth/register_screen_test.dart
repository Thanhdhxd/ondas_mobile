import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:ondas_mobile/features/auth/presentation/screens/register_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class _FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(_FakeAuthEvent());
  });

  setUp(() {
    mockBloc = MockAuthBloc();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockBloc,
        child: const RegisterScreen(),
      ),
    );
  }

  group('RegisterScreen', () {
    testWidgets('renders all fields and submit button', (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildSubject());

      expect(find.byKey(const Key('registerScreen_fullNameField')), findsOneWidget);
      expect(find.byKey(const Key('registerScreen_emailField')), findsOneWidget);
      expect(find.byKey(const Key('registerScreen_passwordField')), findsOneWidget);
      expect(find.byKey(const Key('registerScreen_confirmPasswordField')), findsOneWidget);
      expect(find.byKey(const Key('registerScreen_submitButton')), findsOneWidget);
      expect(find.byKey(const Key('registerScreen_goToLoginButton')), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when state is AuthLoading', (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final submitButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('registerScreen_submitButton')),
      );
      expect(submitButton.onPressed, isNull);
    });

    testWidgets('shows SnackBar with message when state is AuthFailure', (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([
          const AuthLoading(),
          const AuthFailure(message: 'Email already in use'),
        ]),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Email already in use'), findsOneWidget);
    });

    testWidgets('adds RegisterSubmitted event when form is valid and submit is tapped',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildSubject());

      await tester.enterText(
        find.byKey(const Key('registerScreen_fullNameField')),
        'Test User',
      );
      await tester.enterText(
        find.byKey(const Key('registerScreen_emailField')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('registerScreen_passwordField')),
        '123456',
      );
      await tester.enterText(
        find.byKey(const Key('registerScreen_confirmPasswordField')),
        '123456',
      );

      await tester.ensureVisible(find.byKey(const Key('registerScreen_submitButton')));
      await tester.tap(find.byKey(const Key('registerScreen_submitButton')));
      await tester.pump();

      verify(
        () => mockBloc.add(
          const RegisterSubmitted(
            fullName: 'Test User',
            email: 'test@example.com',
            password: '123456',
          ),
        ),
      ).called(1);
    });

    testWidgets('shows validation error when passwords do not match', (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildSubject());

      await tester.enterText(
        find.byKey(const Key('registerScreen_fullNameField')),
        'Test User',
      );
      await tester.enterText(
        find.byKey(const Key('registerScreen_emailField')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('registerScreen_passwordField')),
        '123456',
      );
      await tester.enterText(
        find.byKey(const Key('registerScreen_confirmPasswordField')),
        '654321',
      );

      await tester.ensureVisible(find.byKey(const Key('registerScreen_submitButton')));
      await tester.tap(find.byKey(const Key('registerScreen_submitButton')));
      await tester.pump();

      expect(find.text('Mật khẩu không khớp'), findsOneWidget);
      verifyNever(() => mockBloc.add(any()));
    });

    testWidgets('does not add event when form fields are empty', (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildSubject());

      await tester.ensureVisible(find.byKey(const Key('registerScreen_submitButton')));
      await tester.tap(find.byKey(const Key('registerScreen_submitButton')));
      await tester.pump();

      verifyNever(() => mockBloc.add(any()));
    });

  });
}
