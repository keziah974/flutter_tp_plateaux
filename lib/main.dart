import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/theme_model.dart';

// Mode MOCK : pas d'initialisation Firebase ni de blocs métier.
// Le branchement sur AuthBloc/GameBloc se fera après validation visuelle.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GameBoardApp());
}

class GameBoardApp extends StatelessWidget {
  const GameBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, AppThemeType>(
        builder: (context, themeType) {
          return MaterialApp.router(
            title: 'Game Board',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.of(themeType),
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
