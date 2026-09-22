import 'package:mind_whispers_app/features/auth/data/models/auth_result_model.dart';
import 'package:mind_whispers_app/features/auth/data/models/user_model.dart';

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

  Future<void> logout();

  Future<UserModel> me();

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });
}
