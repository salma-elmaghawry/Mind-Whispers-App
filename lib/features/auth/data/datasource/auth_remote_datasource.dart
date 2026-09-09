import 'package:mind_whispers_app/features/auth/data/models/auth_result_model.dart';
import 'package:mind_whispers_app/features/auth/data/models/user_model.dart';

/// Talks to the `/auth/*` endpoints in api-1.json. Throws raw exceptions
/// (Dio throws [DioException] on any non-2xx response) — [AuthRepositoryImpl]
/// is the only layer that catches them.
abstract class AuthRemoteDataSource {
  Future<AuthResultModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<AuthResultModel> login({
    required String email,
    required String password,
    bool remember = false,
  });

  /// Revokes the current device's token. `device_name` must match the one
  /// sent at register/login — handled internally via [DeviceIdProvider].
  Future<void> logout();

  Future<UserModel> me();
}
