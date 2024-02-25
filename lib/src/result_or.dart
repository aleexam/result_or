import 'errors.dart';

part "result_with.dart";

/// BaseResultOr class. You can use it to define your own ResultOr, based on your own error types
sealed class BaseResultOr<T, T2> {}

/// Main ResultOr class, use it to get value or error from any function
/// Predefined error types are [NonFatalResultError], [FatalResultError] types.
/// You can extend these types, or define custom base error types using [BaseResultOr]
sealed class ResultOr<T> extends BaseResultOr<T, BaseResultError> {
  
  ResultOr();

  /// Function wraps any other function and return either expected value, or error class.
  static ResultOr<T> from<T>(T Function() func, {
    void Function(T data)? onSuccess,
    void Function(BaseResultError error)? onError
  }) {
    try {
      var result = ResultWithData<T>(data: func());
      onSuccess?.call(result.data);
      return result;
    } on NonFatalResultError catch (e) {
      var error = ResultWithError<T>(error: e);
      onError?.call(error.error);
      return error;
    } catch(e, s) {
      var error = ResultWithError<T>(error: FatalResultError(e.toString(), s));
      onError?.call(error.error);
      return error;
    }
  }

  /// Function wraps any other Future function and return either expected value, or error class.
  static Future<ResultOr<T>> fromFuture<T>(Future<T> Function() func, {
    void Function(T data)? onSuccess,
    void Function(BaseResultError error)? onError
  }) async {
    try {
      return ResultWithData<T>(data: await func());
    } on NonFatalResultError catch (e) {
      return ResultWithError<T>(error: e);
    } catch(e, s) {
      return ResultWithError<T>(error: FatalResultError(e.toString(), s));
    }
  }

}
