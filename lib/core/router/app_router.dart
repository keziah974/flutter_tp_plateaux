import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/game/camp_selection_screen.dart';
import '../../presentation/game/difficulty_selection_screen.dart';
import '../../presentation/game/game_screen.dart';
import '../../presentation/home/game_selection_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/profile/stats_screen.dart';
import '../../presentation/shared/not_found_screen.dart';
import '../../presentation/splash/splash_screen.dart';
import '../theme/theme_cubit.dart';
import '../theme/theme_model.dart';

/// Routeur en mode MOCK : pas de redirection d'authentification,
/// la navigation est pilotée directement par les écrans.
/// Les transitions de pages s'adaptent au thème actif :
/// - Futuriste : fade + scale
/// - Ancien : slide depuis la droite
/// - Cosmos : fade + légère rotation
class AppRouter {
  AppRouter._();

  static CustomTransitionPage<void> _page(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final type = context.read<ThemeCubit>().state;
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        switch (type) {
          case AppThemeType.futuriste:
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
                child: child,
              ),
            );
          case AppThemeType.ancien:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            );
          case AppThemeType.cosmos:
            return FadeTransition(
              opacity: curved,
              child: RotationTransition(
                turns: Tween<double>(begin: -0.015, end: 0).animate(curved),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
                  child: child,
                ),
              ),
            );
        }
      },
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    errorPageBuilder: (context, state) =>
        _page(state, const NotFoundScreen()),
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _page(state, const SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _page(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) =>
            _page(state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _page(state, const HomeScreen()),
      ),
      GoRoute(
        path: '/game-select/:gameType',
        pageBuilder: (context, state) => _page(
          state,
          GameSelectionScreen(
            gameType: state.pathParameters['gameType']!,
          ),
        ),
      ),
      GoRoute(
        path: '/difficulty/:gameType',
        pageBuilder: (context, state) => _page(
          state,
          DifficultySelectionScreen(
            gameType: state.pathParameters['gameType']!,
          ),
        ),
      ),
      GoRoute(
        path: '/camp/:gameType',
        pageBuilder: (context, state) => _page(
          state,
          CampSelectionScreen(
            gameType: state.pathParameters['gameType']!,
            difficulty: state.uri.queryParameters['difficulty'] ?? 'easy',
          ),
        ),
      ),
      GoRoute(
        path: '/game/:gameType',
        pageBuilder: (context, state) => _page(
          state,
          GameScreen(gameType: state.pathParameters['gameType']!),
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) =>
            _page(state, const ProfileScreen()),
      ),
      GoRoute(
        path: '/stats',
        pageBuilder: (context, state) => _page(state, const StatsScreen()),
      ),
    ],
  );
}
