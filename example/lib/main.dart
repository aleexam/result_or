import 'package:result_or/result_or.dart';

import 'functions.dart';

void main() async {
  /// With ResultOr simply call your functions in bloc/store/etc, or anywhere else, wrapped in ResultOr.
  /// Get result data or error.

  // Simple function example
  var result = ResultOr.from(someFunction);

  if (result case ResultWithData())  {
    print(result.data);
  } else if (result case ResultWithError()) {
    print(result.error.message);
  }

  // Callback function example
  ResultOr.from(someFunction,
      onSuccess: (data) {
        print(data);
      },
      onError: (error) {
        print(error.message);
      }
  );

  // Future function example + switch/case
  var result2 = await ResultOr.fromFuture(someFutureFunction);

  switch (result2) {
    case ResultWithData():
      print(result2.data);
    case ResultWithError():
      print(result2.error.message);
  }

  // Parametrized function example
  var result3 = ResultOr.from(() => someFunctionWithParam(2));

  if (result3 case ResultWithData())  {
    print(result3.data);
  } else if (result3 case ResultWithError()) {
    print(result3.error.message);
  }

  // Parametrized future function example
  var result4 = await ResultOr.fromFuture(() => someFutureFunctionWithParam("Param"));

  if (result4 case ResultWithData())  {
    print(result4.data);
  } else if (result4 case ResultWithError()) {
    print(result4.error.message);
  }

  // Using extensions
  someFunction.resultOr(
      onSuccess: (data) {
        print(data);
      },
      onError: (error) {
        print(error.message);
      }
  );

  // Using extensions and async without callbacks
  var result5 = await someFutureFunction.resultOr();

  if (result5 case ResultWithData())  {
    print(result5.data);
  } else if (result5 case ResultWithError()) {
    print(result5.error.message);
  }

  // Using extensions and async with params
  var result6 = await (() => someFutureFunctionWithParam("param")).resultOr();

  if (result6 case ResultWithData())  {
    print(result6.data);
  } else if (result6 case ResultWithError()) {
    print(result6.error.message);
  }

}