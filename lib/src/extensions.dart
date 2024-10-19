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
