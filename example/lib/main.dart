import 'package:result_or/result_or.dart';

import 'example_functions.dart';

void main() async {
  /// With ResultOr simply call your functions in bloc/store/etc, or anywhere else, wrapped in ResultOr.
  /// Get result data or error.

  var result = ResultOr(someFunction);
  // var result = someFunction.resultOr();

  if (result case ResultData()) {
    print(result.data);
  } else if (result case ResultError()) {
    print(result.error.message);
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
  var result2 = await ResultOr.async(someFutureFunction);

  switch (result2) {
    case ResultData():
      print(result2.data);
    case ResultError():
      print(result2.error.message);
  }

  // Parametrized function example
  var result3 = ResultOr(() => someFunctionWithParam(2));

  if (result3 case ResultData()) {
    print(result3.data);
  } else if (result3 case ResultError()) {
    print(result3.error.message);
  }

  // Parametrized future function example
  var result4 =
      await ResultOr.async(() => someFutureFunctionWithParam("Param"));

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
  var result5 = await someFutureFunction.resultOr();

  if (result5 case ResultData()) {
    print(result5.data);
  } else if (result5 case ResultError()) {
    print(result5.error.message);
  }

  // Using extensions and async with params
  var result6 = await (() => someFutureFunctionWithParam("param")).resultOr();

  if (result6 case ResultData()) {
    print(result6.data);
  } else if (result6 case ResultError()) {
    print(result6.error.message);
  }
}
