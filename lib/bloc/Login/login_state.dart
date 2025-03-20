part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String email;
  final String displayName;
  final String role;

  const LoginSuccess(this.email, this.displayName,this.role);

  @override
  List<Object?> get props => [email, displayName,role];
}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class LoginRequireSetPassword extends LoginState {
  final String email;

  const LoginRequireSetPassword(this.email);

  @override
  List<Object?> get props => [email];
}

class SetPasswordSuccess extends LoginState {}

class SetPasswordFailure extends LoginState {
  final String message;
  const SetPasswordFailure(this.message);

  @override
  List<Object?> get props => [message];
}
