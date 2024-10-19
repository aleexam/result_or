import 'dart:async';

import 'package:flutter/foundation.dart';

import 'errors.dart';

part "return_types.dart";

/// BaseResultOr class. You can use it to define your own ResultOr, based on your own error types
abstract class BaseResultOr<T, T2> {}

/// Main ResultOr class, use it to get value or error from any function
/// Predefined error types are [NonFatalResultError], [FatalResultError] types.
/// You can extend these types, or define custom base error types using [BaseResultOr]
sealed class ResultOr<T> extends BaseResultOr<T, BaseResultError> {
  ResultOr();

  /// Function wraps any other function and return either expected value, or error class.
  static ResultOr<T> from<T>(T Function() func,
      {void Function(T data)? onSuccess, void Function(BaseResultError error)? onError}) {
    try {
      var result = ResultData<T>(data: func());
      onSuccess?.call(result.data);
      return result;
    } on NonFatalResultError catch (e) {
      var error = ResultError<T>(error: e);
      onError?.call(error.error);
      if (kDebugMode) {
        print(e);
      }
      return error;
    } catch (e, s) {
      var error = ResultError<T>(error: FatalResultError(e.toString(), s, e));
      onError?.call(error.error);
      if (kDebugMode) {
        print(e);
        print(s);
      }
      return error;
    }
  }

  /// Function wraps any other Future function and return either expected value, or error class.
  static Future<ResultOr<T>> fromFuture<T>(Future<T> Function() func,
      {void Function(T data)? onSuccess,
      void Function(BaseResultError error)? onError}) async {
    try {
      var result = ResultData<T>(data: await func());
      onSuccess?.call(result.data);
      return result;
    } on NonFatalResultError catch (e) {
      var error = ResultError<T>(error: e);
      onError?.call(error.error);
      if (kDebugMode) {
        print(e);
      }
      return error;
    } catch (e, s) {
      var error = ResultError<T>(error: FatalResultError(e.toString(), s, e));
      onError?.call(error.error);
      if (kDebugMode) {
        print(e);
        print(s);
      }
      return error;
    }
  }

  /// Function wraps any Stream and return Stream<ResultOr<T> with either expected value, or error class type.
  static Stream<ResultOr<T>> fromStream<T>(Stream<T> stream) {
    return Stream.eventTransformed(stream.map((data) {
      return ResultData(data: data);
    }), (sink) => _ResultOrDuplicateSink(sink));
  }
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
    if (e is NonFatalResultError) {
      var error = ResultError<T>(error: e);
      _outputSink.add(error);
    } else {
      var error = ResultError<T>(error: FatalResultError(e.toString(), s, e));
      _outputSink.add(error);
    }
    if (kDebugMode) {
      print(e);
      print(s);
    }
  }

  @override
  void close() {
    _outputSink.close();
  }
}
