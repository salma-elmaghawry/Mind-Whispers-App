import 'package:dartz/dartz.dart';
import 'package:mind_whispers_app/core/error_handling/failures.dart';
import 'package:mind_whispers_app/features/auth/domain/entities/auth_session.dart';
import 'package:mind_whispers_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthSession>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
    bool remember = false,
  });

  Future<Either<Failure, Unit>> logout();

  /// Confirms the locally persisted token is still valid and returns the
  /// current user, refreshing the persisted role as a side effect.
  Future<Either<Failure, User>> me();

  /// Synchronous, local-only check used by [AuthCubit.checkAuthStatus] to
  /// decide whether it's even worth calling [me].
  bool get hasPersistedToken;
}
