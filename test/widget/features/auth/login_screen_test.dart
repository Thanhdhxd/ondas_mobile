import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:ondas_mobile/features/auth/presentation/screens/login_screen.dart';

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
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders email field, password field and submit button', (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildSubject());

      expect(find.byKey(const Key('loginScreen_emailField')), findsOneWidget);
      expect(find.byKey(const Key('loginScreen_passwordField')), findsOneWidget);
      expect(find.byKey(const Key('loginScreen_submitButton')), findsOneWidget);
      expect(find.byKey(const Key('loginScreen_forgotPasswordButton')), findsOneWidget);
      expect(find.byKey(const Key('loginScreen_goToRegisterButton')), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when state is AuthLoading', (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final submitButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('loginScreen_submitButton')),
      );
      expect(submitButton.onPressed, isNull);
    });

    testWidgets('shows SnackBar with message when state is AuthFailure', (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([
          const AuthLoading(),
          const AuthFailure(message: 'Invalid credentials'),
        ]),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('adds LoginSubmitted event when form is valid and submit is tapped',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildSubject());

      await tester.enterText(
        find.byKey(const Key('loginScreen_emailField')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('loginScreen_passwordField')),
        '123456',
      );

      await tester.ensureVisible(find.byKey(const Key('loginScreen_submitButton')));
      await tester.tap(find.byKey(const Key('loginScreen_submitButton')));
      await tester.pump();

      verify(
        () => mockBloc.add(
          const LoginSubmitted(email: 'test@example.com', password: '123456'),
        ),
      ).called(1);
    });

    testWidgets('does not add event when email is empty', (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildSubject());

      await tester.ensureVisible(find.byKey(const Key('loginScreen_submitButton')));
      await tester.tap(find.byKey(const Key('loginScreen_submitButton')));
      await tester.pump();

      verifyNever(() => mockBloc.add(any()));
    });

  });
}
