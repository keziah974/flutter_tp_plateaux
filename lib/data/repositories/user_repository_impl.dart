import '../../domain/entities/user_model.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/firestore_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final FirestoreDatasource _firestoreDatasource;

  UserRepositoryImpl({required this._firestoreDatasource});

  @override
  Future<void> createUser(UserModel user) {
    return _firestoreDatasource.setUserDocument(user.uid, user.toMap());
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestoreDatasource.getUserDocument(uid);
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<void> updateUser(UserModel user) {
    return _firestoreDatasource.setUserDocument(user.uid, user.toMap());
  }
}
