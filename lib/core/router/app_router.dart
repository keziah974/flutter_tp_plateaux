import 'package:go_router/go_router.dart';

import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/game/difficulty_selection_screen.dart';
import '../../presentation/game/game_screen.dart';
import '../../presentation/home/game_selection_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/profile/stats_screen.dart';
import '../../presentation/splash/splash_screen.dart';

/// Routeur en mode MOCK : pas de redirection d'authentification,
/// la navigation est pilotée directement par les écrans.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
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
        path: '/game-select/:gameType',
        builder: (context, state) => GameSelectionScreen(
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
