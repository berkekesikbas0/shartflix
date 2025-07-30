import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

/// Server failure - API related errors
class ServerFailure extends Failure {
  const ServerFailure(String message, [int? code]) : super(message, code);

  @override
  String toString() => 'ServerFailure(message: $message, code: $code)';
}

/// Network failure - Connection related errors
class NetworkFailure extends Failure {
  const NetworkFailure(String message, [int? code]) : super(message, code);

  @override
  String toString() => 'NetworkFailure(message: $message)';
}

/// Authentication failure - Auth related errors
class AuthFailure extends Failure {
  const AuthFailure(String message, [int? code]) : super(message, code);

  @override
  String toString() => 'AuthFailure(message: $message, code: $code)';
}

/// Validation failure - Input validation errors
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure(String message, [this.errors, int? code])
    : super(message, code);

  @override
  List<Object?> get props => [message, code, errors];

  @override
  String toString() => 'ValidationFailure(message: $message, errors: $errors)';
}

/// Cache failure - Local storage errors
class CacheFailure extends Failure {
  const CacheFailure(String message, [int? code]) : super(message, code);

  @override
  String toString() => 'CacheFailure(message: $message)';
}

/// Unknown failure - Unexpected errors
class UnknownFailure extends Failure {
  const UnknownFailure(String message, [int? code]) : super(message, code);

  @override
  String toString() => 'UnknownFailure(message: $message)';
}
