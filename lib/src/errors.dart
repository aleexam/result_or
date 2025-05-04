/// Base error class for ResultOr concept
abstract class BaseResultError {
  final String? _message;
  final dynamic originalError;

  BaseResultError(this._message, this.originalError);

  String get message => _message ?? runtimeType.toString();
}

/// Exception class for Non-Fatal exceptions
/// You can extend this class to use your own class
class NonFatalResultError extends BaseResultError implements Exception {
  NonFatalResultError(super.message, [super.originalError]);
}

/// Error class for Fatal Errors
/// Better use for unexpected errors
class FatalResultError extends BaseResultError implements Error {
  final StackTrace? _stack;

  FatalResultError(super.message, this._stack, [super.originalError]);

  @override
  StackTrace? get stackTrace => _stack;
}
