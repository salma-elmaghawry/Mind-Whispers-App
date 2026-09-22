import 'package:dio/dio.dart';
import 'package:mind_whispers_app/core/helpers/device_id.dart';
import 'package:mind_whispers_app/core/network/api_endpoints.dart';
import 'package:mind_whispers_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:mind_whispers_app/features/auth/data/models/auth_result_model.dart';
import 'package:mind_whispers_app/features/auth/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  final DeviceIdProvider _deviceIdProvider;

  AuthRemoteDataSourceImpl(this._dio, this._deviceIdProvider);

  @override
  Future<AuthResultModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'device_name': _deviceIdProvider.deviceId,
      },
    );
    return AuthResultModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResultModel> login({
    required String email,
    required String password,
    bool remember = false,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
        'device_name': _deviceIdProvider.deviceId,
        'remember': remember,
      },
    );
    return AuthResultModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _dio.post(
      ApiEndpoints.logout,
      data: {'device_name': _deviceIdProvider.deviceId},
    );
  }

  @override
  Future<UserModel> me() async {
    final response = await _dio.get(ApiEndpoints.me);
    return UserModel.fromJson(
      (response.data as Map<String, dynamic>)['user'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _dio.post(ApiEndpoints.forgotPassword, data: {'email': email});
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _dio.post(
      ApiEndpoints.resetPassword,
      data: {
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }
}
