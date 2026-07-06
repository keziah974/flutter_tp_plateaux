import '../entities/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> authStateChanges();

  UserModel? get currentUser;

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String pseudo,
  });

  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
