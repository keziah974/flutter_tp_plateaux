import '../application/auth/auth_bloc.dart';
import '../application/game/game_bloc.dart';
import '../data/datasources/firebase_auth_datasource.dart';
import '../data/datasources/firestore_datasource.dart';
import '../data/datasources/local_storage_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/local_storage_repository_impl.dart';
import '../data/repositories/score_repository_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/local_storage_repository.dart';
import '../domain/repositories/score_repository.dart';
import '../domain/repositories/user_repository.dart';
import 'theme/theme_cubit.dart';

/// Minimal hand-rolled service locator (no get_it dependency).
///
/// Wires datasources -> repositories -> blocs/cubits in one place so that
/// the Firebase SDK and SharedPreferences never leak into blocs or widgets.
class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  late final FirebaseAuthDatasource _firebaseAuthDatasource =
      FirebaseAuthDatasource();
  late final FirestoreDatasource _firestoreDatasource = FirestoreDatasource();
  late final LocalStorageDatasource _localStorageDatasource =
      LocalStorageDatasource();

  late final UserRepository userRepository = UserRepositoryImpl(
    firestoreDatasource: _firestoreDatasource,
  );

  late final AuthRepository authRepository = AuthRepositoryImpl(
    authDatasource: _firebaseAuthDatasource,
    userRepository: userRepository,
  );

  late final ScoreRepository scoreRepository = ScoreRepositoryImpl(
    firestoreDatasource: _firestoreDatasource,
  );

  late final LocalStorageRepository localStorageRepository =
      LocalStorageRepositoryImpl(datasource: _localStorageDatasource);

  AuthBloc createAuthBloc() => AuthBloc(authRepository: authRepository);

  GameBloc createGameBloc() => GameBloc(
        scoreRepository: scoreRepository,
        localStorageRepository: localStorageRepository,
        currentUserId: () => authRepository.currentUser?.uid,
      );

  ThemeCubit createThemeCubit() =>
      ThemeCubit(localStorageRepository: localStorageRepository);
}

