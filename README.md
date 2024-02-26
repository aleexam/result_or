Easy error handling implementation base on ResultOrError/Either idea. <br /> <br />
Requires Dart 3.0+ <br />

## Features

With ResultOr simply call your functions in bloc/store/etc, or anywhere else, wrapped in ResultOr.from() <br />
You get result data or error object instead of uncaught exception. <br />
Works with any functions: future/simple sync/parametrized functions <br />

## Usage

```dart

// Simple function example
var result = ResultOr.from(someFunction);
// With extensions: var result = someFunction.resultOr();

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
// With extensions: var result = someFunction.resultOr(onSuccess, onError);

// Used sample function
String someFunction() {
  // Just random value to randomize success / errors
  var isSuccess = Random().nextBool();

  if (isSuccess) {
    // Just return your data if everything is ok
    return "success payload";
  } else {
    // Just throw an exception if something wrong. Manually expected to throw NonFatalResultError
    // Also of course exception could be throw by itself
    throw Exception("error");
  }
}
```

More examples

```dart
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

// Using extensions and async with params
var result6 = await (() => someFutureFunctionWithParam("param")).resultOr();

if (result6 case ResultWithData())  {
  print(result6.data);
} else if (result6 case ResultWithError()) {
  print(result6.error.message);
}

```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
