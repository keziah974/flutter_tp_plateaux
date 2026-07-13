import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_model.dart';

/// Gère le thème actif de l'application et le persiste
/// dans SharedPreferences sous la clé 'selected_theme'.
class ThemeCubit extends Cubit<AppThemeType> {
  static const String _prefsKey = 'selected_theme';

  ThemeCubit() : super(AppThemeType.cosmos) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    final match = AppThemeType.values.where((t) => t.name == stored);
    if (match.isNotEmpty) emit(match.first);
  }

  Future<void> switchTheme(AppThemeType type) async {
    emit(type);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, type.name);
  }
}
