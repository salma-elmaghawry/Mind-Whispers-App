import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mind_whispers_app/core/error_handling/error_mapper.dart';
import 'package:mind_whispers_app/core/error_handling/failures.dart';
import 'package:mind_whispers_app/core/network/dio_client.dart';
import 'package:mind_whispers_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:mind_whispers_app/features/auth/domain/entities/auth_session.dart';
import 'package:mind_whispers_app/features/auth/domain/entities/user.dart';
import 'package:mind_whispers_app/features/auth/repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key the router guard and splash screen read to know
/// which role's home to open (see AppRouter._guardedRoute, SplashScreen).
const String userRolePrefsKey = 'user_role';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SharedPreferences _prefs;

  AuthRepositoryImpl(this._remoteDataSource, this._prefs);

  @override
  bool get hasPersistedToken {
    final token = _prefs.getString(authTokenPrefsKey);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<Either<Failure, AuthSession>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final model = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      final session = model.toEntity();
      await _persistSession(session);
      return Right(session);
    } catch (e) {
      final failure = ErrorMapper.map(e);
      // A 422 on `email` at this point survived AppValidators' own format
      // check client-side, so in practice it's Laravel's uniqueness rule
      // ("The email has already been taken.") — surface the friendlier,
      // pre-translated failure instead of the raw field message.
      if (failure is ValidationFailure && failure.errors.containsKey('email')) {
        return Left(
          EmailAlreadyInUseFailure(message: 'auth.errors.email_in_use'.tr()),
        );
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
    bool remember = false,
  }) async {
    try {
      final model = await _remoteDataSource.login(
        email: email,
        password: password,
        remember: remember,
      );
      final session = model.toEntity();
      await _persistSession(session);
      return Right(session);
    } catch (e) {
      final failure = ErrorMapper.map(e);
      // Laravel's default login flow throws its validation exception with
      // the "these credentials do not match" message attached to `email`,
      // so a 422 on that field here means invalid credentials, not a
      // malformed request (format is already checked client-side).
      if (failure is ValidationFailure && failure.errors.containsKey('email')) {
        return Left(
          InvalidCredentialsFailure(message: 'auth.errors.invalid_credentials'.tr()),
        );
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _clearSession();
      return const Right(unit);
    } catch (e) {
      // Sign-out is a local intent as much as a server call: even if the
      // revoke request fails (offline, timeout, already-expired token),
      // forget the session on this device so the user isn't stuck signed
      // in. Worst case the server-side token just outlives this session
      // until it naturally expires.
      await _clearSession();
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, User>> me() async {
    try {
      final model = await _remoteDataSource.me();
      final user = model.toEntity();
      await _persistRole(user);
      return Right(user);
    } catch (e) {
      final failure = ErrorMapper.map(e);
      if (failure is UnauthorizedFailure) {
        await _clearSession();
      }
      return Left(failure);
    }
  }

  Future<void> _persistSession(AuthSession session) async {
    await _prefs.setString(authTokenPrefsKey, session.token);
    await _persistRole(session.user);
  }

  Future<void> _persistRole(User user) async {
    final role = user.primaryRole;
    if (role != null) {
      await _prefs.setString(userRolePrefsKey, role.wireValue);
    } else {
      await _prefs.remove(userRolePrefsKey);
    }
  }

  Future<void> _clearSession() async {
    await _prefs.remove(authTokenPrefsKey);
    await _prefs.remove(userRolePrefsKey);
  }
}
