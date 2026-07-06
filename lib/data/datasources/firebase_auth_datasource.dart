import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Thin wrapper around FirebaseAuth so the repository layer never touches
/// the Firebase SDK types directly.
class FirebaseAuthDatasource {
  final fb.FirebaseAuth _auth;

  FirebaseAuthDatasource({fb.FirebaseAuth? auth})
      : _auth = auth ?? fb.FirebaseAuth.instance;

  Stream<fb.User?> authStateChanges() => _auth.authStateChanges();

  fb.User? get currentUser => _auth.currentUser;

  Future<fb.User> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<fb.User> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<void> signOut() => _auth.signOut();
}
