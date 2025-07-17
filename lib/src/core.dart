import 'dart:async';
import 'errors.dart';

part "return_types.dart";
part 'error_reporter.dart';

/// BaseResultOr class. You can use it to define your own ResultOr, based on your own error types
abstract class BaseResultOr<T, T2> {}

/// Main ResultOr class, use it to get value or error from any function
/// Predefined error types are [NonFatalResultError], [FatalResultError] types.
/// You can extend these types, or define custom base error types using [BaseResultOr]
sealed class ResultOr<T> extends BaseResultOr<T, BaseResultError> {
  /// Wraps any other function and return either expected value, or error class.
  factory ResultOr(
    T Function() func, {
    void Function(T data)? onSuccess,
    void Function(BaseResultError error)? onError,
  }) {
    try {
      final result = ResultData<T>(data: func());
      onSuccess?.call(result.data);
      return result;
    } catch (e, s) {
      final error = _mapThrown<T>(e, s);
      ResultOrHandledErrorReporter._reportCaughtError(e, s);
      onError?.call(error.error);
      return error;
    }
  }

  /// Wraps any other Future function and return either expected value, or error class.
  static Future<ResultOr<T>> async<T>(
    Future<T> Function() func, {
    void Function(T data)? onSuccess,
    void Function(BaseResultError error)? onError,
  }) async {
    try {
      final result = ResultData<T>(data: await func());
      onSuccess?.call(result.data);
      return result;
    } catch (e, s) {
      final error = _mapThrown<T>(e, s);
      ResultOrHandledErrorReporter._reportCaughtError(e, s);
      onError?.call(error.error);
      return error;
    }
  }

  /// Wraps any Stream and return Stream<ResultOr<T> with either expected value, or error class type.
  static Stream<ResultOr<T>> stream<T>(Stream<T> stream) {
    return Stream.eventTransformed(stream.map((data) {
      return ResultData(data: data);
    }), (sink) => _ResultOrDuplicateSink(sink));
  }

  static ResultError<T> _mapThrown<T>(Object e, StackTrace? s) => ResultError<T>(
    error: switch (e) {
      BaseResultError err => err,
      Exception ex => NonFatalResultError(ex.toString(), s, ex),
      Error err => FatalResultError(err.toString(), s, err),
      Object other => UnexpectedResultError(other.toString(), s, other),
    },
  );
}

class _ResultOrDuplicateSink<T> implements EventSink<ResultOr<T>> {
  final EventSink<ResultOr<T>> _outputSink;

  _ResultOrDuplicateSink(this._outputSink);

  @override
  void add(ResultOr<T> data) {
    _outputSink.add(data);
  }

  @override
  void addError(Object e, [StackTrace? s]) {
    final error = ResultOr._mapThrown<T>(e, s);
    ResultOrHandledErrorReporter._reportCaughtError(e, s ?? StackTrace.current);
    _outputSink.add(error);
  }

  @override
  void close() {
    _outputSink.close();
  }
}
