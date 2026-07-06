import 'package:equatable/equatable.dart';

import '../../domain/entities/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Internal event fired whenever the underlying Firebase auth stream
/// reports a change; not part of the public API surface described in the
/// spec, but required to bridge the stream into bloc events.
class AuthUserChanged extends AuthEvent {
  final UserModel? user;
  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String pseudo;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.pseudo,
  });

  @override
  List<Object?> get props => [email, password, pseudo];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}
