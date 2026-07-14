import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'theme_cubit.dart';
import 'theme_model.dart';

/// Raccourcis pour accéder au thème actif depuis un build method.
/// (S'abonne au ThemeCubit : le widget se reconstruit au changement de thème.)
extension ThemeContextX on BuildContext {
  AppThemeType get appThemeType => watch<ThemeCubit>().state;
  AppColors get appColors => AppColors.of(appThemeType);
  AppTypography get appTypography => AppTypography.of(appThemeType);
}
