import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/reset_password_bloc.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/reset_password_event.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/reset_password_state.dart';
import 'package:ondas_mobile/features/auth/presentation/screens/reset_password_screen.dart';

class MockResetPasswordBloc
    extends MockBloc<ResetPasswordEvent, ResetPasswordState>
    implements ResetPasswordBloc {}

void main() {
  late MockResetPasswordBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(
      const ResetPasswordSubmitted(
        email: '',
        otp: '',
        newPassword: '',
      ),
    );
  });

  setUp(() {
    mockBloc = MockResetPasswordBloc();
    when(() => mockBloc.state).thenReturn(const ResetPasswordInitial());
  });

  Widget buildSubject({String email = 'test@example.com'}) {
    return MaterialApp(
      home: BlocProvider<ResetPasswordBloc>.value(
        value: mockBloc,
        child: ResetPasswordScreen(email: email),
      ),
    );
  }

  group('ResetPasswordScreen', () {
    testWidgets('renders OTP, new password, and confirm password fields',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(
        find.byKey(const Key('resetPasswordScreen_otpField')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('resetPasswordScreen_newPasswordField')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('resetPasswordScreen_confirmPasswordField')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('resetPasswordScreen_submitButton')),
        findsOneWidget,
      );
    });

    testWidgets('shows loading indicator when state is Loading', (tester) async {
      when(() => mockBloc.state).thenReturn(const ResetPasswordLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(
              find.byKey(const Key('resetPasswordScreen_submitButton')),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('shows error snackbar when state is Failure', (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([
          const ResetPasswordLoading(),
          const ResetPasswordFailure(message: 'OTP không hợp lệ'),
        ]),
        initialState: const ResetPasswordInitial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('OTP không hợp lệ'), findsOneWidget);
    });

    testWidgets('adds ResetPasswordSubmitted when form is valid and submitted',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(
        find.byKey(const Key('resetPasswordScreen_otpField')),
        '123456',
      );
      await tester.enterText(
        find.byKey(const Key('resetPasswordScreen_newPasswordField')),
        'newpassword123',
      );
      await tester.enterText(
        find.byKey(const Key('resetPasswordScreen_confirmPasswordField')),
        'newpassword123',
      );

      await tester.ensureVisible(
        find.byKey(const Key('resetPasswordScreen_submitButton')),
      );
      await tester.tap(find.byKey(const Key('resetPasswordScreen_submitButton')));
      await tester.pump();

      verify(
        () => mockBloc.add(
          const ResetPasswordSubmitted(
            email: 'test@example.com',
            otp: '123456',
            newPassword: 'newpassword123',
          ),
        ),
      ).called(1);
    });

    testWidgets('does not add event when OTP is invalid format', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(
        find.byKey(const Key('resetPasswordScreen_otpField')),
        'abc',
      );
      await tester.enterText(
        find.byKey(const Key('resetPasswordScreen_newPasswordField')),
        'newpassword123',
      );
      await tester.enterText(
        find.byKey(const Key('resetPasswordScreen_confirmPasswordField')),
        'newpassword123',
      );

      await tester.ensureVisible(
        find.byKey(const Key('resetPasswordScreen_submitButton')),
      );
      await tester.tap(find.byKey(const Key('resetPasswordScreen_submitButton')));
      await tester.pump();

      verifyNever(() => mockBloc.add(any()));
    });

    testWidgets('does not add event when passwords do not match', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(
        find.byKey(const Key('resetPasswordScreen_otpField')),
        '123456',
      );
      await tester.enterText(
        find.byKey(const Key('resetPasswordScreen_newPasswordField')),
        'newpassword123',
      );
      await tester.enterText(
        find.byKey(const Key('resetPasswordScreen_confirmPasswordField')),
        'differentpassword',
      );

      await tester.ensureVisible(
        find.byKey(const Key('resetPasswordScreen_submitButton')),
      );
      await tester.tap(find.byKey(const Key('resetPasswordScreen_submitButton')));
      await tester.pump();

      verifyNever(() => mockBloc.add(any()));
    });

    testWidgets('navigates to /login on Success', (tester) async {
      String? navigatedLocation;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => BlocProvider<ResetPasswordBloc>.value(
              value: mockBloc,
              child: const ResetPasswordScreen(email: 'test@example.com'),
            ),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) {
              navigatedLocation = '/login';
              return const Scaffold(body: Text('Login'));
            },
          ),
        ],
      );

      whenListen(
        mockBloc,
        Stream.fromIterable([
          const ResetPasswordLoading(),
          const ResetPasswordSuccess(),
        ]),
        initialState: const ResetPasswordInitial(),
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();
      await tester.pump();

      expect(navigatedLocation, '/login');
    });
  });
}
