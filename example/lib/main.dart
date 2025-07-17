import 'package:result_or/result_or.dart';

import 'example_functions.dart';

void main() async {
  /// With ResultOr simply call your functions in bloc/store/etc, or anywhere else, wrapped in ResultOr.
  /// Get result data or error.

  final result = ResultOr(someFunction);
  // final result = someFunction.resultOr();

  if (result case ResultData(:final data)) {
    print(data);
  } else if (result case ResultError(:final error)) {
    print(error.message);
  }

  // Callback function example
  ResultOr(someFunction, onSuccess: (data) {
    print(data);
  }, onError: (error) {
    print(error.message);
  });

  // Future function example + switch/case
  // This one comes with exhaustiveness, good to use
  // when you need return something from parent function
  final result2 = await ResultOr.async(someFutureFunction);

  switch (result2) {
    case ResultData():
      print(result2.data);
    case ResultError():
      print(result2.error.message);
  }

  // Parametrized function example
  final result3 = ResultOr(() => someFunctionWithParam(2));

  // .when example
  result3.when(
      (data) => print(data),
      (error) => print(error.message)
  );

  // Parametrized future function example
  final result4 = await someFutureFunctionWithParam("Param").resultOr();

  if (result4 case ResultData()) {
    print(result4.data);
  } else if (result4 case ResultError()) {
    print(result4.error.message);
  }

  // Using extensions
  someFunction.resultOr(onSuccess: (data) {
    print(data);
  }, onError: (error) {
    print(error.message);
  });

  // Using extensions and async without callbacks
  final result5 = await someFutureFunction.resultOr();

  if (result5 case ResultData(:final data)) {
    print(data);
  } else if (result5 case ResultError(:final error)) {
    print(error.message);
  }
}
