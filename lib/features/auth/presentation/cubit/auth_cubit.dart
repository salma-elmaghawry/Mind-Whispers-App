import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_whispers_app/core/bloc/base_bloc.dart';
import 'package:mind_whispers_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:mind_whispers_app/features/auth/repository/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    if (!_repository.hasPersistedToken) {
      emit(
        state.copyWith(
          status: Status.failure,
          action: AuthAction.checkStatus,
          clearUser: true,
        ),
      );
      return;
    }

    emit(state.copyWith(status: Status.loading, action: AuthAction.checkStatus));
    final result = await _repository.me();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
          action: AuthAction.checkStatus,
          clearUser: true,
        ),
      ),
      (user) => emit(
        state.copyWith(status: Status.success, user: user, action: AuthAction.checkStatus),
      ),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(state.copyWith(status: Status.loading, action: AuthAction.register));
    final result = await _repository.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
          action: AuthAction.register,
        ),
      ),
      (session) => emit(
        state.copyWith(status: Status.success, user: session.user, action: AuthAction.register),
      ),
    );
  }

  Future<void> login({
    required String email,
    required String password,
    bool remember = false,
  }) async {
    emit(state.copyWith(status: Status.loading, action: AuthAction.login));
    final result = await _repository.login(email: email, password: password, remember: remember);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
          action: AuthAction.login,
        ),
      ),
      (session) => emit(
        state.copyWith(status: Status.success, user: session.user, action: AuthAction.login),
      ),
    );
  }

  Future<void> logout() async {
    emit(state.copyWith(status: Status.loading, action: AuthAction.logout));
    final result = await _repository.logout();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
          action: AuthAction.logout,
          clearUser: true,
        ),
      ),
      (_) => emit(
        state.copyWith(status: Status.success, action: AuthAction.logout, clearUser: true),
      ),
    );
  }

  Future<void> forgotPassword({required String email}) async {
    emit(
      state.copyWith(status: Status.loading, action: AuthAction.forgotPassword),
    );
    final result = await _repository.forgotPassword(email: email);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
          action: AuthAction.forgotPassword,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: Status.success,
          action: AuthAction.forgotPassword,
        ),
      ),
    );
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(
      state.copyWith(status: Status.loading, action: AuthAction.resetPassword),
    );
    final result = await _repository.resetPassword(
      email: email,
      otp: otp,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          failure: failure,
          action: AuthAction.resetPassword,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: Status.success,
          action: AuthAction.resetPassword,
        ),
      ),
    );
  }
}
