import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_bloc.dart';
import '../../application/auth/auth_state.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/game/difficulty_selection_screen.dart';
import '../../presentation/game/game_screen.dart';
import '../../presentation/game/mode_selection_screen.dart';
import '../../presentation/home/game_selection_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/profile/stats_screen.dart';

class AppRouter {
  AppRouter._();

  static GoRouter build(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: _AuthBlocRefreshStream(authBloc),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final isAuthRoute =
            state.matchedLocation == '/login' || state.matchedLocation == '/register';

        if (!isAuthenticated && !isAuthRoute) return '/login';
        if (isAuthenticated && (isAuthRoute || state.matchedLocation == '/')) {
          return '/home';
        }
        if (!isAuthenticated) return null;
        if (state.matchedLocation == '/') return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/game-select',
          builder: (context, state) => const GameSelectionScreen(),
        ),
        GoRoute(
          path: '/mode-select/:gameType',
          builder: (context, state) => ModeSelectionScreen(
            gameType: state.pathParameters['gameType']!,
          ),
        ),
        GoRoute(
          path: '/difficulty/:gameType',
          builder: (context, state) => DifficultySelectionScreen(
            gameType: state.pathParameters['gameType']!,
          ),
        ),
        GoRoute(
          path: '/game/:gameType',
          builder: (context, state) => GameScreen(
            gameType: state.pathParameters['gameType']!,
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsScreen(),
        ),
      ],
    );
  }
}

/// Bridges the AuthBloc's stream into a [Listenable] so go_router can
/// re-evaluate its redirect logic whenever the auth state changes.
class _AuthBlocRefreshStream extends ChangeNotifier {
  late final Stream<AuthState> _subscription;

  _AuthBlocRefreshStream(AuthBloc authBloc) {
    _subscription = authBloc.stream.asBroadcastStream();
    _subscription.listen((_) => notifyListeners());
  }
}
