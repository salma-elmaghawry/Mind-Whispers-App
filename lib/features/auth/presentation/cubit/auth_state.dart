import 'package:mind_whispers_app/core/bloc/base_bloc.dart';
import 'package:mind_whispers_app/core/error_handling/failures.dart';
import 'package:mind_whispers_app/features/auth/domain/entities/user.dart';

enum AuthAction { checkStatus, register, login, logout, forgotPassword, resetPassword }

class AuthState extends BaseState {
  final User? user;
  final Failure? failure;
  final AuthAction? action;

  const AuthState({
    super.status = Status.initial,
    super.message,
    this.user,
    this.failure,
    this.action,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    Status? status,
    String? message,
    User? user,
    Failure? failure,
    AuthAction? action,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: message,
      user: clearUser ? null : (user ?? this.user),
      failure: failure,
      action: action ?? this.action,
    );
  }

  @override
  List<Object?> get props => [status, message, user, failure, action];
}
