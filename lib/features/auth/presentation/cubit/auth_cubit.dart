import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_whispers_app/core/bloc/base_bloc.dart';
import 'package:mind_whispers_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:mind_whispers_app/features/auth/repository/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState());

  /// Called once at app boot (see SplashScreen). A Sanctum token can outlive
  /// the app (up to 30 days with `remember`), so a token found in local
  /// storage isn't trusted on its own — this confirms it against `/auth/me`
  /// before treating the user as signed in.
  ///
  /// `BaseState` only has initial/loading/success/failure, so "there's no
  /// session yet" is represented as `Status.failure` with no [User] and no
  /// message — it's an expected outcome (every signed-out launch hits it),
  /// not something a listener should show as an error.
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
}
