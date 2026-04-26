import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:ondas_mobile/features/profile/presentation/screens/profile_screen.dart';

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState> implements ProfileBloc {}

class _FakeProfileEvent extends Fake implements ProfileEvent {}

void main() {
  late MockProfileBloc mockBloc;

  const tProfile = UserProfile(
    id: 'uuid-1',
    email: 'test@example.com',
    displayName: 'Test User',
    role: 'USER',
  );

  setUpAll(() {
    registerFallbackValue(_FakeProfileEvent());
  });

  setUp(() {
    mockBloc = MockProfileBloc();
  });

  Widget buildSubject() {
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) => BlocProvider<ProfileBloc>.value(
            value: mockBloc,
            child: const ProfileScreen(),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  group('ProfileScreen', () {
    testWidgets('shows loading indicator when state is ProfileLoading', (tester) async {
      when(() => mockBloc.state).thenReturn(const ProfileLoading());

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows profile content when state is ProfileLoaded', (tester) async {
      when(() => mockBloc.state).thenReturn(const ProfileLoaded(tProfile));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.byKey(const Key('profileScreen_editButton')), findsOneWidget);
      expect(find.byKey(const Key('profileScreen_changePasswordButton')), findsOneWidget);
      expect(find.byKey(const Key('profileScreen_logoutButton')), findsOneWidget);
    });

    testWidgets('shows error view with retry button when state is ProfileFailure', (tester) async {
      when(() => mockBloc.state).thenReturn(const ProfileFailure('Server error'));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Server error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('adds ProfileLoadRequested when Retry is tapped on error state', (tester) async {
      when(() => mockBloc.state).thenReturn(const ProfileFailure('Server error'));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockBloc.add(const ProfileLoadRequested())).called(1);
    });

    testWidgets('opens EditProfileDialog when edit button is tapped', (tester) async {
      when(() => mockBloc.state).thenReturn(const ProfileLoaded(tProfile));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.byKey(const Key('profileScreen_editButton')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('editProfileDialog_displayNameField')), findsOneWidget);
      expect(find.byKey(const Key('editProfileDialog_avatarUrlField')), findsOneWidget);
    });

    testWidgets('adds ProfileUpdateRequested when edit profile is submitted', (tester) async {
      when(() => mockBloc.state).thenReturn(const ProfileLoaded(tProfile));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.byKey(const Key('profileScreen_editButton')));
      await tester.pumpAndSettle();

      final nameField = find.byKey(const Key('editProfileDialog_displayNameField'));
      await tester.enterText(nameField, 'New Name');

      await tester.tap(find.byKey(const Key('editProfileDialog_submitButton')));
      await tester.pumpAndSettle();

      verify(
        () => mockBloc.add(
          const ProfileUpdateRequested(displayName: 'New Name'),
        ),
      ).called(1);
    });

    testWidgets('opens ChangePasswordDialog when change password is tapped', (tester) async {
      when(() => mockBloc.state).thenReturn(const ProfileLoaded(tProfile));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.byKey(const Key('profileScreen_changePasswordButton')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('changePasswordDialog_currentPasswordField')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('changePasswordDialog_newPasswordField')), findsOneWidget);
    });

    testWidgets('adds ProfileChangePasswordRequested when change password is submitted',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const ProfileLoaded(tProfile));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.byKey(const Key('profileScreen_changePasswordButton')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('changePasswordDialog_currentPasswordField')),
        'oldpass123',
      );
      await tester.enterText(
        find.byKey(const Key('changePasswordDialog_newPasswordField')),
        'newpass123',
      );

      await tester.tap(find.byKey(const Key('changePasswordDialog_submitButton')));
      await tester.pumpAndSettle();

      verify(
        () => mockBloc.add(
          const ProfileChangePasswordRequested(
            currentPassword: 'oldpass123',
            newPassword: 'newpass123',
          ),
        ),
      ).called(1);
    });

    testWidgets('shows logout confirmation dialog when logout is tapped', (tester) async {
      when(() => mockBloc.state).thenReturn(const ProfileLoaded(tProfile));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.byKey(const Key('profileScreen_logoutButton')));
      await tester.pumpAndSettle();

      expect(find.text('Log Out'), findsWidgets);
      expect(find.text('Are you sure you want to log out?'), findsOneWidget);
    });

    testWidgets('adds ProfileLogoutRequested when logout is confirmed', (tester) async {
      when(() => mockBloc.state).thenReturn(const ProfileLoaded(tProfile));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.byKey(const Key('profileScreen_logoutButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('logoutConfirmDialog_confirmButton')));
      await tester.pumpAndSettle();

      verify(() => mockBloc.add(const ProfileLogoutRequested())).called(1);
    });

    testWidgets('navigates to /login when ProfileLogoutSuccess is emitted', (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([
          const ProfileLoading(),
          const ProfileLogoutSuccess(),
        ]),
        initialState: const ProfileLoaded(tProfile),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('shows success SnackBar when ProfilePasswordChangeSuccess is emitted',
        (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([
          const ProfileLoading(),
          const ProfilePasswordChangeSuccess(),
        ]),
        initialState: const ProfileLoaded(tProfile),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Password changed successfully'), findsOneWidget);
    });
  });
}
