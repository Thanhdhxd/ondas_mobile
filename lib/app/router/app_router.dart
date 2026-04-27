import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_mobile/app/shell/main_shell_screen.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/storage/secure_storage.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/forgot_password_bloc.dart';
import 'package:ondas_mobile/features/auth/presentation/bloc/reset_password_bloc.dart';
import 'package:ondas_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:ondas_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:ondas_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:ondas_mobile/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:ondas_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:ondas_mobile/features/library/presentation/screens/library_screen.dart';
import 'package:ondas_mobile/features/player/presentation/screens/player_screen.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/history_bloc.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ondas_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:ondas_mobile/features/profile/presentation/screens/history_screen.dart';
import 'package:ondas_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:ondas_mobile/features/search/presentation/screens/search_screen.dart';
import 'package:ondas_mobile/features/playlist/presentation/screens/playlist_detail_screen.dart';

class AppRouter {
  AppRouter._();

  static const _authRoutes = {'/login', '/register', '/forgot-password', '/reset-password'};

  static GoRouter create() {
    return GoRouter(
      initialLocation: '/home',
      redirect: _guard,
      routes: [
        GoRoute(
          path: '/player',
          name: 'player',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const PlayerScreen(),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curve = CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              );
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(curve),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => BlocProvider<AuthBloc>(
            create: (_) => sl<AuthBloc>(),
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => BlocProvider<AuthBloc>(
            create: (_) => sl<AuthBloc>(),
            child: const RegisterScreen(),
          ),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgotPassword',
          builder: (context, state) => BlocProvider<ForgotPasswordBloc>(
            create: (_) => sl<ForgotPasswordBloc>(),
            child: const ForgotPasswordScreen(),
          ),
        ),
        GoRoute(
          path: '/reset-password',
          name: 'resetPassword',
          builder: (context, state) => BlocProvider<ResetPasswordBloc>(
            create: (_) => sl<ResetPasswordBloc>(),
            child: ResetPasswordScreen(
              email: state.extra as String,
            ),
          ),
        ),
        GoRoute(
          path: '/history',
          name: 'history',
          builder: (context, state) => BlocProvider<HistoryBloc>(
            create: (_) => sl<HistoryBloc>(),
            child: const HistoryScreen(),
          ),
        ),
        ShellRoute(
          builder: (context, state, child) => MainShellScreen(child: child),
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/search',
              name: 'search',
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
              path: '/library',
              name: 'library',
              builder: (context, state) => const LibraryScreen(),
            ),
            GoRoute(
              path: '/playlists/:id',
              name: 'playlistDetail',
              builder: (context, state) => PlaylistDetailScreen(
                playlistId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => BlocProvider<ProfileBloc>(
                create: (_) => sl<ProfileBloc>()..add(const ProfileLoadRequested()),
                child: const ProfileScreen(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Future<String?> _guard(BuildContext context, GoRouterState state) async {
    final secureStorage = sl<SecureStorage>();
    final token = await secureStorage.getAccessToken();
    final isLoggedIn = token != null;
    final isOnAuthRoute = _authRoutes.contains(state.matchedLocation);

    if (!isLoggedIn && !isOnAuthRoute) return '/login';
    if (isLoggedIn && isOnAuthRoute) return '/home';
    return null;
  }
}
