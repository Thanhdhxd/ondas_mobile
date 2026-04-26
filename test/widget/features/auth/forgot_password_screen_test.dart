import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/forgot_password_bloc.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/forgot_password_event.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/forgot_password_state.dart';
import 'package:ondas_mobile/features/auth/presentation/screens/forgot_password_screen.dart';

class MockForgotPasswordBloc
    extends MockBloc<ForgotPasswordEvent, ForgotPasswordState>
    implements ForgotPasswordBloc {}

void main() {
  late MockForgotPasswordBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(
      const ForgotPasswordSubmitted(email: ''),
    );
  });

  setUp(() {
    mockBloc = MockForgotPasswordBloc();
    when(() => mockBloc.state).thenReturn(const ForgotPasswordInitial());
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<ForgotPasswordBloc>.value(
        value: mockBloc,
        child: const ForgotPasswordScreen(),
      ),
    );
  }

  group('ForgotPasswordScreen', () {
    testWidgets('renders email field and submit button', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(
        find.byKey(const Key('forgotPasswordScreen_emailField')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('forgotPasswordScreen_submitButton')),
        findsOneWidget,
      );
    });

    testWidgets('shows loading indicator when state is Loading', (tester) async {
      when(() => mockBloc.state).thenReturn(const ForgotPasswordLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(
              find.byKey(const Key('forgotPasswordScreen_submitButton')),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('shows error snackbar when state is Failure', (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([
          const ForgotPasswordLoading(),
          const ForgotPasswordFailure(message: 'Đã xảy ra lỗi'),
        ]),
        initialState: const ForgotPasswordInitial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Đã xảy ra lỗi'), findsOneWidget);
    });

    testWidgets('adds ForgotPasswordSubmitted when form is valid and submitted',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(
        find.byKey(const Key('forgotPasswordScreen_emailField')),
        'test@example.com',
      );

      await tester.ensureVisible(
        find.byKey(const Key('forgotPasswordScreen_submitButton')),
      );
      await tester.tap(find.byKey(const Key('forgotPasswordScreen_submitButton')));
      await tester.pump();

      verify(
        () => mockBloc.add(
          const ForgotPasswordSubmitted(email: 'test@example.com'),
        ),
      ).called(1);
    });

    testWidgets('does not add event when email is empty', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.ensureVisible(
        find.byKey(const Key('forgotPasswordScreen_submitButton')),
      );
      await tester.tap(find.byKey(const Key('forgotPasswordScreen_submitButton')));
      await tester.pump();

      verifyNever(() => mockBloc.add(any()));
    });

    testWidgets('navigates to /reset-password on Success', (tester) async {
      const testEmail = 'test@example.com';
      String? navigatedLocation;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => BlocProvider<ForgotPasswordBloc>.value(
              value: mockBloc,
              child: const ForgotPasswordScreen(),
            ),
          ),
          GoRoute(
            path: '/reset-password',
            builder: (context, state) {
              navigatedLocation = '/reset-password';
              return const Scaffold(body: Text('Reset Password'));
            },
          ),
        ],
      );

      whenListen(
        mockBloc,
        Stream.fromIterable([
          const ForgotPasswordLoading(),
          const ForgotPasswordSuccess(),
        ]),
        initialState: const ForgotPasswordInitial(),
      );

      // Pre-fill email so the extra param is available
      final emailController = TextEditingController(text: testEmail);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      // Trigger listener
      await tester.pump();
      await tester.pump();

      expect(navigatedLocation, '/reset-password');

      emailController.dispose();
    });
  });
}
