part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class LoginWithEmailPassword extends LoginEvent {
  final String email;
  final String password;
  const LoginWithEmailPassword(this.email, this.password);
}

class LoginWithGoogle extends LoginEvent {}

class LogoutEvent extends LoginEvent {}

class CheckSessionEvent extends LoginEvent {}
