import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

import 'failures.dart';

class ErrorMapper {
  static Failure map(dynamic error, [StackTrace? stackTrace]) {
    if (error is DioException) {
      return _mapDioException(error);
    }

    if (error is SocketException || error is TimeoutException) {
      return NetworkFailure(message: 'errors.network_error'.tr());
    }

    if (error is HttpException || error is FormatException) {
      return ServerFailure(message: 'errors.server_error'.tr());
    }

    if (kDebugMode) {
      debugPrint('ErrorMapper: unmapped ${error.runtimeType}: $error');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }

    return UnexpectedFailure(message: 'errors.unexpected_error'.tr());
  }

  static Failure _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkFailure(message: 'errors.network_error'.tr());
      default:
        break;
    }

    final data = error.response?.data;
    final serverMessage = (data is Map && data['message'] is String)
        ? data['message'] as String
        : null;

    switch (error.response?.statusCode) {
      case 401:
        return UnauthorizedFailure(
          message: serverMessage ?? 'errors.unauthorized'.tr(),
        );
      case 403:
        return ForbiddenFailure(
          message: serverMessage ?? 'errors.forbidden'.tr(),
        );
      case 404:
        return NotFoundFailure(
          message: serverMessage ?? 'errors.not_found'.tr(),
        );
      case 422:
        final rawErrors = (data is Map && data['errors'] is Map)
            ? data['errors'] as Map
            : const {};
        final errors = rawErrors.map(
          (key, value) => MapEntry(key.toString(), List<String>.from(value)),
        );
        return ValidationFailure(
          message: serverMessage ?? 'errors.validation_error'.tr(),
          errors: errors,
        );
      default:
        return ServerFailure(
          message: serverMessage ?? 'errors.server_error'.tr(),
        );
    }
  }
}
