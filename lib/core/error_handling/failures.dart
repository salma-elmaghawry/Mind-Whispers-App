import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

// Auth failures

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({required super.message});
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure({required super.message});
}

// API response failures (mapped from HTTP status codes, see ErrorMapper)

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message});
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({required super.message});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;

  const ValidationFailure({required super.message, this.errors = const {}});

  @override
  List<Object> get props => [message, errors];
}

// Network failures

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

// Server failures

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

// Unexpected failures

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}
