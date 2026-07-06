import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'application/auth/auth_bloc.dart';
import 'application/auth/auth_event.dart';
import 'core/router/app_router.dart';
import 'core/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GameBoardApp());
}

class GameBoardApp extends StatelessWidget {
  const GameBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locator = ServiceLocator.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => locator.createAuthBloc()..add(const AuthCheckRequested()),
        ),
        BlocProvider<ThemeCubit>(create: (_) => locator.createThemeCubit()),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.build(context.read<AuthBloc>());
          return BlocBuilder<ThemeCubit, bool>(
            builder: (context, isDark) {
              return MaterialApp.router(
                title: 'Game Board',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                routerConfig: router,
              );
            },
          );
        },
      ),
    );
  }
}
