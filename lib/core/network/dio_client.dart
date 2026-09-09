import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key the auth feature (see AuthRepositoryImpl) writes
/// the Sanctum token to. Kept here so both sides agree on it without the
/// network layer depending on the auth feature.
const String authTokenPrefsKey = 'auth_token';

class DioClient {
  final SharedPreferences _sharedPreferences;

  DioClient(this._sharedPreferences);

  Dio get dio {
    final dio = Dio(
      BaseOptions(
        // See api-1.json's `servers` entry — the live API has no `/v1`
        // segment (unlike the draft in API_CONTRACT.md).
        baseUrl:
            dotenv.env['API_BASE_URL'] ??
            'https://mind-whispers.laravel.cloud/api',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _sharedPreferences.getString(authTokenPrefsKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: true,
        ),
      );
    }

    return dio;
  }
}
