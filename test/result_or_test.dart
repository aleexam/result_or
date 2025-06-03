import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:result_or/result_or.dart';

class TestNonFatalError extends NonFatalResultError {
  TestNonFatalError(super.message);
}

class TestFatalError extends FatalResultError {
  TestFatalError(super.message, super._stack);
}

void main() {
  group('ResultOr.from tests', () {
    test('should return ResultData on success', () {
      var result = ResultOr.from(() => 17);

      expect(result.dataOrNull != null, isTrue);
      expect(result.errorOrNull == null, isTrue);

      expect(result, isA<ResultData<int>>());
      expect((result as ResultData<int>).data, 17);
    });

    test('should return ResultError on NonFatalResultError', () {
      var result = ResultOr.from<int>(() {
        throw TestNonFatalError('Non-fatal error');
      });

      expect(result.dataOrNull == null, isTrue);
      expect(result.errorOrNull != null, isTrue);

      expect(result, isA<ResultError<int>>());
      expect((result as ResultError<int>).error, isA<NonFatalResultError>());
      expect(result.error.message, 'Non-fatal error');
    });

    test('should return ResultError with NonFatalResultError for Exception', () {
      var result = ResultOr.from<int>(() {
        throw Exception('Generic error');
      });

      expect(result, isA<ResultError<int>>());
      expect((result as ResultError<int>).error, isA<NonFatalResultError>());
      expect(result.error.message, contains('Exception: Generic error'));
    });

    test('should return ResultError with FatalResultError for Error', () {
      var result = ResultOr.from<int>(() {
        throw ArgumentError('Fatal error');
      });

      expect(result, isA<ResultError<int>>());
      expect((result as ResultError<int>).error, isA<FatalResultError>());
      expect(result.error.message, contains('Invalid argument(s): Fatal error'));
    });

    test('should call onSuccess callback when successful', () {
      int? callbackValue;

      ResultOr.from(() => 2, onSuccess: (value) => callbackValue = value);

      expect(callbackValue, 2);
    });

    test('should call onError callback when error occurs', () {
      BaseResultError? callbackError;

      ResultOr.from<int>(() => throw TestNonFatalError('Test error'),
          onError: (error) => callbackError = error);

      expect(callbackError, isA<NonFatalResultError>());
      expect(callbackError!.message, 'Test error');
    });
  });

  group('ResultOr.fromFuture tests', () {
    test('should return ResultData on success', () async {
      var result = await ResultOr.fromFuture(() async => 100);

      expect(result, isA<ResultData<int>>());
      expect((result as ResultData<int>).data, 100);
    });

    test('should return ResultError on NonFatalResultError', () async {
      var result = await ResultOr.fromFuture<int>(() async {
        throw TestNonFatalError('Future error');
      });

      expect(result, isA<ResultError<int>>());
      expect((result as ResultError<int>).error, isA<NonFatalResultError>());
      expect(result.error.message, 'Future error');
    });

    test('should return ResultError with FatalResultError for Error', () async {
      var result = await ResultOr.fromFuture<int>(() async {
        throw ArgumentError('Future fatal error');
      });

      expect(result, isA<ResultError<int>>());
      expect((result as ResultError<int>).error, isA<FatalResultError>());
      expect(result.error.message, contains('Invalid argument(s): Future fatal error'));
    });

    test('should return ResultError with NonFatalResultError for Exception', () async {
      var result = await ResultOr.fromFuture<int>(() async {
        throw Exception('Future generic error');
      });

      expect(result, isA<ResultError<int>>());
      expect((result as ResultError<int>).error, isA<NonFatalResultError>());
      expect(result.error.message, contains('Exception: Future generic error'));
    });

    test('should call onSuccess callback when successful', () async {
      int? callbackValue;

      await ResultOr.fromFuture(() async => 123, onSuccess: (value) => callbackValue = value);

      expect(callbackValue, 123);
    });

    test('should call onError callback when error occurs', () async {
      BaseResultError? callbackError;

      await ResultOr.fromFuture<int>(() async => throw TestNonFatalError('Future test error'),
          onError: (error) => callbackError = error);

      expect(callbackError, isA<NonFatalResultError>());
      expect(callbackError!.message, 'Future test error');
    });
  });

  group('ResultOr.fromStream tests', () {
    test('should convert successful stream values to ResultData', () async {
      final controller = StreamController<int>();
      final values = [10, 20, 30, 40, 50];
      final resultValues = <ResultOr<int>>[];

      final stream = ResultOr.fromStream(controller.stream);
      final completer = Completer<void>();

      final subscription = stream.listen(
        (resultOr) {
          resultValues.add(resultOr);
          if (resultValues.length == values.length) {
            completer.complete();
          }
        },
        onError: (e) => completer.completeError(e),
      );

      for (var value in values) {
        controller.add(value);
      }

      await completer.future.timeout(const Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('Stream test timed out'));

      await controller.close();
      await subscription.cancel();

      expect(resultValues.length, values.length);

      for (int i = 0; i < values.length; i++) {
        expect(resultValues[i], isA<ResultData<int>>());
        expect((resultValues[i] as ResultData<int>).data, values[i]);
      }
    });

    test('should convert stream errors to ResultError', () async {
      final controller = StreamController<int>();
      final error = TestNonFatalError('Stream error');
      final resultValues = <ResultOr<int>>[];
      final completer = Completer<void>();

      final stream = ResultOr.fromStream(controller.stream);

      final subscription = stream.listen(
        (resultOr) {
          resultValues.add(resultOr);
          if (resultValues.length == 2) {
            completer.complete();
          }
        },
        onError: (e) => completer.completeError(e),
      );

      controller.add(55);
      controller.addError(error);

      await completer.future.timeout(const Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('Stream test timed out'));

      await controller.close();
      await subscription.cancel();

      expect(resultValues.length, 2);
      expect(resultValues[0], isA<ResultData<int>>());
      expect((resultValues[0] as ResultData<int>).data, 55);

      expect(resultValues[1], isA<ResultError<int>>());
      expect((resultValues[1] as ResultError<int>).error.message, error.message);
    });
  });

  group('Extension methods tests', () {
    test('map should transform data on success', () {
      final result = ResultData<int>(data: 5).map((x) => 'Result is $x');
      expect(result, isA<ResultData<String>>());
      expect((result as ResultData<String>).data, 'Result is 5');
    });

    test('map should return same error without transforming', () {
      final error = ResultError<int>(error: TestNonFatalError('Error!'));
      final result = error.map((x) => 'Should not be called');
      expect(result, isA<ResultError<String>>());
      expect((result as ResultError<String>).error.message, 'Error!');
    });

    test('mapError should transform error in ResultError', () {
      final result = ResultError<int>(error: TestNonFatalError('original'));

      final transformed = result.mapError(
            (error) => TestNonFatalError('transformed: ${error.message}'),
      );

      expect(transformed, isA<ResultError<int>>());
      expect((transformed as ResultError<int>).error, isA<TestNonFatalError>());
      expect(transformed.error.message, 'transformed: original');
    });

    test('mapError should not modify ResultData', () {
      final result = ResultData<int>(data: 123);

      final transformed = result.mapError(
            (error) => TestNonFatalError('should not be called'),
      );

      expect(transformed, isA<ResultData<int>>());
      expect((transformed as ResultData<int>).data, 123);
    });

    test('mapError should preserve original type parameter', () {
      ResultOr<String> result = ResultError<String>(error: TestNonFatalError('error'));
      final transformed = result.mapError((e) => TestNonFatalError('new ${e.message}'));

      expect(transformed, isA<ResultError<String>>());
      expect((transformed as ResultError<String>).error.message, 'new error');
    });

    test('mapError can transform to different error subtype', () {
      ResultOr<int> result = ResultError<int>(error: TestNonFatalError('some error'));

      final transformed = result.mapError(
            (e) => TestFatalError('fatal: ${e.message}', StackTrace.current),
      );

      expect(transformed, isA<ResultError<int>>());
      expect((transformed as ResultError<int>).error, isA<TestFatalError>());
      expect(transformed.error.message, contains('fatal: some error'));
    });

    test('andThen should chain another ResultOr on success', () {
      final result = ResultData<int>(data: 2).andThen((x) {
        return ResultData<String>(data: 'OK $x');
      });

      expect(result, isA<ResultData<String>>());
      expect((result as ResultData<String>).data, 'OK 2');
    });

    test('andThen should short-circuit on error', () {
      final result = ResultError<int>(error: TestNonFatalError('fail')).andThen((x) {
        return ResultData<String>(data: 'Should not run');
      });

      expect(result, isA<ResultError<String>>());
      expect((result as ResultError<String>).error.message, 'fail');
    });

    test('should handle sync function extensions', () {
      int successValue = 76;
      int successFunction() => successValue;

      var result = successFunction.resultOr();

      expect(result, isA<ResultData<int>>());
      expect((result as ResultData<int>).data, successValue);
    });

    test('should handle sync function extensions with errors', () {
      int errorFunction() => throw TestNonFatalError('Extension error');

      var result = errorFunction.resultOr();

      expect(result, isA<ResultError<int>>());
      expect((result as ResultError<int>).error, isA<NonFatalResultError>());
      expect(result.error.message, 'Extension error');
    });

    test('should handle async function extensions', () async {
      Future<int> successFunction() async => 99;

      var result = await successFunction.resultOr();

      expect(result, isA<ResultData<int>>());
      expect((result as ResultData<int>).data, 99);
    });

    test('should handle async function extensions with errors', () async {
      Future<int> errorFunction() async => throw TestNonFatalError('Async extension error');

      var result = await errorFunction.resultOr();

      expect(result, isA<ResultError<int>>());
      expect((result as ResultError<int>).error, isA<NonFatalResultError>());
      expect(result.error.message, 'Async extension error');
    });
  });

  group('Error types tests', () {
    test('should handle custom NonFatalResultError', () {
      var result = ResultOr.from<int>(() {
        throw TestNonFatalError('Custom non-fatal error');
      });

      expect(result, isA<ResultError<int>>());
      expect((result as ResultError<int>).error, isA<TestNonFatalError>());
      expect(result.error.message, 'Custom non-fatal error');
    });

    test('BaseResultError message should fallback to class name', () {
      final error = TestNonFatalError(null);

      expect(error.message, 'TestNonFatalError');
    });

    test('should include stack trace in FatalResultError', () {
      final stackTrace = StackTrace.current;
      final error = FatalResultError('Fatal error', stackTrace);

      expect(error.stackTrace, stackTrace);
    });
  });

  group('Additional tests', () {
    test('should handle void return type', () {
      void voidFunction() {}

      var result = ResultOr.from<void>(voidFunction);

      expect(result, isA<ResultData<void>>());
    });

    test('Nested ResultOr', () async {
      Future<ResultOr<int>> nestedFunction() async {
        return ResultOr.from(() => 123);
      }

      var result = await ResultOr.fromFuture(nestedFunction);

      expect(result, isA<ResultData<ResultOr<int>>>());
      var innerResult = (result as ResultData<ResultOr<int>>).data;
      expect(innerResult, isA<ResultData<int>>());
      expect((innerResult as ResultData<int>).data, 123);
    });

    test('onError throws, exception bubbles up', () {
      expect(
        () => ResultOr.from<int>(
          () => throw TestNonFatalError('fail'),
          onError: (_) => throw Exception('onError exception'),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('fromFuture handles Future.error', () async {
      var result =
          await ResultOr.fromFuture<int>(() => Future.error(TestNonFatalError('future fail')));
      expect(result, isA<ResultError<int>>());
      expect((result as ResultError<int>).error, isA<TestNonFatalError>());
      expect(result.error.message, 'future fail');
    });

    test('fromFuture handles synchronous throw inside async closure', () async {
      var result = await ResultOr.fromFuture<int>(() async {
        throw TestNonFatalError('sync inside async');
      });
      expect(result, isA<ResultError<int>>());
      expect((result as ResultError<int>).error.message, 'sync inside async');
    });

    test('fromStream multiple errors handled sequentially', () async {
      final controller = StreamController<int>();
      final errors = [TestNonFatalError('err1'), TestNonFatalError('err2')];
      final results = <ResultOr<int>>[];
      final completer = Completer<void>();
      final stream = ResultOr.fromStream(controller.stream);

      final subscription = stream.listen(
        (result) {
          results.add(result);
          if (results.length == 3) completer.complete();
        },
        onError: (e) => completer.completeError(e),
      );

      controller.add(1);
      controller.addError(errors[0]);
      controller.addError(errors[1]);

      await completer.future.timeout(const Duration(seconds: 5));
      await controller.close();
      await subscription.cancel();

      expect(results.length, 3);
      expect(results[0], isA<ResultData<int>>());
      expect((results[1] as ResultError<int>).error.message, 'err1');
      expect((results[2] as ResultError<int>).error.message, 'err2');
    });

    test('ResultData isSuccess/isError getters', () {
      final data = ResultData<int>(data: 1);
      expect(data.isSuccess, isTrue);
      expect(data.isError, isFalse);
    });

    test('ResultError isSuccess/isError getters', () {
      final error = ResultError<int>(error: TestNonFatalError('fail'));
      expect(error.isSuccess, isFalse);
      expect(error.isError, isTrue);
    });

    test('ResultOr.from handles thrown Error (not Exception) as FatalResultError', () {
      var result = ResultOr.from<int>(() {
        throw StateError('fatal!');
      });
      expect(result, isA<ResultError<int>>());
      expect((result as ResultError<int>).error, isA<FatalResultError>());
      expect(result.error.message, contains('fatal!'));
    });

    test('ResultOr can handle void synchronous code that throws', () {
      void voidError() => throw TestNonFatalError('void error');
      var result = ResultOr.from<void>(voidError);
      expect(result, isA<ResultError<void>>());
      expect((result as ResultError<void>).error.message, 'void error');
    });

    test('Nested map and andThen calls', () {
      final result = ResultData<int>(data: 10).map((n) => n * 2).andThen((n) => n > 10
          ? ResultData<String>(data: 'Big: $n')
          : ResultError<String>(error: TestNonFatalError('Too small')));
      expect(result, isA<ResultData<String>>());
      expect((result as ResultData<String>).data, 'Big: 20');
    });

    test('Nested map andThen returns error path', () {
      final result = ResultData<int>(data: 3).map((n) => n * 2).andThen((n) => n > 10
          ? ResultData<String>(data: 'Big: $n')
          : ResultError<String>(error: TestNonFatalError('Too small')));
      expect(result, isA<ResultError<String>>());
      expect((result as ResultError<String>).error.message, 'Too small');
    });

    test('Nested ResultError inside ResultData', () async {
      Future<ResultOr<int>> nestedFailingFunction() async {
        return ResultOr.from(() => throw TestNonFatalError('inner fail'));
      }

      var result = await ResultOr.fromFuture(nestedFailingFunction);
      expect((result as ResultData).data, isA<ResultError<int>>());
    });

    test('FatalResultError retains stack trace', () {
      final trace = StackTrace.current;
      final error = FatalResultError('message', trace);
      expect(error.stackTrace, trace);
    });

    test('Stream after close returns no values', () async {
      final controller = StreamController<int>();
      controller.close();
      await Future.delayed(Duration.zero);
      final stream = ResultOr.fromStream(controller.stream);
      final values = await stream.toList();
      expect(values.isEmpty, isTrue);
    });

    test('onError rethrows error', () {
      expect(
            () => ResultOr.from(() => throw TestNonFatalError('err'), onError: (e) => throw e),
        throwsA(isA<TestNonFatalError>()),
      );
    });

    test('Unexpected thrown', () {
      var result = ResultOr.from(() => throw 12);
      expect((result as ResultError).error, isA<UnexpectedResultError>());
    });

    test('Another map test', () {
      final result = ResultOr.from(() => 27)
          .map((n) => "${n * 2}");

      expect((result as ResultData).data, equals("54"));
    });

  });
}
