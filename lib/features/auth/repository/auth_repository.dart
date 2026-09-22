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

  Future<Either<Failure, User>> me();

  Future<Either<Failure, Unit>> forgotPassword({required String email});

  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });

  bool get hasPersistedToken;
}
