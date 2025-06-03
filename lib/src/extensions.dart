import 'dart:async';

import '../result_or.dart';

extension ResultOrFunctionExtSync<T> on T Function() {
  /// Get resultOr from function itself (expected value or error object)
  ResultOr<T> resultOr({
    void Function(T data)? onSuccess,
    void Function(BaseResultError error)? onError,
  }) {
    return ResultOr.from(this, onSuccess: onSuccess, onError: onError);
  }
}

extension ResultOrFunctionExtAsync<T> on Future<T> Function() {
  /// Get resultOr from function itself (expected value or error object)
  Future<ResultOr<T>> resultOr({
    void Function(T data)? onSuccess,
    void Function(BaseResultError error)? onError,
  }) {
    return ResultOr.fromFuture(this, onSuccess: onSuccess, onError: onError);
  }
}

/// Extension methods for ResultOr<T> to enable functional-style transformations.
extension ResultOrExt<T> on ResultOr<T> {

  /// Chains another ResultOr-producing function if this result is successful.
  ///
  /// - If this is a [ResultData], applies [transform] to its data and returns the result.
  /// - If this is a [ResultError], returns the same error wrapped in a new ResultError of type R.
  ResultOr<R> andThen<R>(ResultOr<R> Function(T) transform) {
    switch (this) {
      case ResultData(:final data):
        return transform(data);
      case ResultError(:final error):
        return ResultError<R>(error: error);
    }
  }

  /// Maps the successful result data to a new type using [transform].
  ///
  /// - If this is a [ResultData], applies [transform] to the data and wraps in a new ResultData.
  /// - If this is a [ResultError], returns the same error with the new type.
  ResultOr<U> map<U>(U Function(T value) transform) {
    switch (this) {
      case ResultData(:final data):
        return ResultData<U>(data: transform(data));
      case ResultError(:final error):
        return ResultError<U>(error: error);
    }
  }

  /// Transforms the error inside [ResultError] using [transform].
  ///
  /// - If this is a [ResultError], applies [transform] to its error and returns new ResultError.
  /// - If this is a [ResultData], returns the same success unchanged.
  ResultOr<T> mapError(BaseResultError Function(BaseResultError error) transform) {
    if (this is ResultError<T>) {
      final original = (this as ResultError<T>).error;
      return ResultError<T>(error: transform(original));
    } else {
      return this;
    }
  }
}