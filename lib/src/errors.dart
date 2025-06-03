/// Base error class for ResultOr concept
abstract class BaseResultError {
  final String? _message;
  final StackTrace? _stack;
  final dynamic originalError;

  BaseResultError(this._message, this._stack, this.originalError);

  String get message => _message ?? runtimeType.toString();

  StackTrace? get stackTrace => _stack;
}

/// Exception class for Non-Fatal exceptions
/// You can extend this class to use your own class
class NonFatalResultError extends BaseResultError implements Exception {
  NonFatalResultError(super.message, [super._stack, super.originalError]);
}

/// Error class for Fatal Errors
/// Better use for critical errors
class FatalResultError extends BaseResultError implements Error {
  FatalResultError(super.message, [super._stack, super.originalError]);
}

/// Error class for unexpected objects thrown
/// Better use for unexpected errors
class UnexpectedResultError extends BaseResultError implements Error {
  UnexpectedResultError(super.message, [super._stack, super.originalError]);
}
