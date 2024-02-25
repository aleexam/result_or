
/// Base error class for ResultOr concept
abstract class BaseResultError {
  final String? _message;
  final dynamic originalError;

  BaseResultError(this._message, this.originalError);

  String get message => _message ?? runtimeType.toString();
}

/// Error class for Non-Fatal Errors
/// You can extend this class to use your own errors class
/// For example ApiError, UIError, etc
class NonFatalResultError extends BaseResultError implements Exception {
  NonFatalResultError(super.message, [super.originalError]);
}

/// Error class for Fatal Errors
/// Better use for handling fatal exceptions
class FatalResultError extends BaseResultError implements Exception {
  final StackTrace? stack;

  FatalResultError(super.message, this.stack, [super.originalError]);
}