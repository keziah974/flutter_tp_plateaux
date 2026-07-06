import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/local_storage_repository.dart';

class ThemeCubit extends Cubit<bool> {
  final LocalStorageRepository _localStorageRepository;

  ThemeCubit({required this._localStorageRepository}) : super(false) {
    _load();
  }

  Future<void> _load() async {
    final isDark = await _localStorageRepository.getTheme();
    emit(isDark);
  }

  Future<void> toggle() async {
    final next = !state;
    emit(next);
    await _localStorageRepository.setTheme(next);
  }
}
