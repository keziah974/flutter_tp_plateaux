import '../entities/user_model.dart';

abstract class UserRepository {
  Future<void> createUser(UserModel user);
  Future<UserModel?> getUser(String uid);
  Future<void> updateUser(UserModel user);
}
