import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _authDatasource;
  final UserRepository _userRepository;

  AuthRepositoryImpl({
    required this._authDatasource,
    required this._userRepository,
  });

  @override
  UserModel? get currentUser {
    final user = _authDatasource.currentUser;
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      pseudo: user.displayName ?? 'Joueur',
      avatarEmoji: '🎲',
      createdAt: DateTime.now(),
    );
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _authDatasource.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _fetchUserModel(user.uid, fallbackPseudo: user.displayName);
    });
  }

  Future<UserModel> _fetchUserModel(
    String uid, {
    String? fallbackPseudo,
  }) async {
    final existing = await _userRepository.getUser(uid);
    if (existing != null) return existing;
    return UserModel(
      uid: uid,
      pseudo: fallbackPseudo ?? 'Joueur',
      avatarEmoji: '🎲',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String pseudo,
  }) async {
    try {
      final user = await _authDatasource.signUp(
        email: email,
        password: password,
      );
      final model = UserModel(
        uid: user.uid,
        pseudo: pseudo,
        avatarEmoji: '🎲',
        createdAt: DateTime.now(),
      );
      await _userRepository.createUser(model);
      return model;
    } on fb.FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authDatasource.signIn(
        email: email,
        password: password,
      );
      return _fetchUserModel(user.uid, fallbackPseudo: user.displayName);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  @override
  Future<void> signOut() => _authDatasource.signOut();

  Exception _mapAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Exception('Cet email est déjà utilisé.');
      case 'invalid-email':
        return Exception('Adresse email invalide.');
      case 'weak-password':
        return Exception('Mot de passe trop faible.');
      case 'user-not-found':
        return Exception('Aucun compte ne correspond à cet email.');
      case 'wrong-password':
      case 'invalid-credential':
        return Exception('Mot de passe incorrect.');
      default:
        return Exception(e.message ?? 'Erreur d\'authentification.');
    }
  }
}
