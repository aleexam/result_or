# ResultOr

Easy and safe error handling built on the `ResultOr` / `Either` pattern.  
Requires **Dart 3.0+**

## ✨ Features

- Wrap any function (sync, async, or parameterized) or stream with `ResultOr()` or use `.resultOr()` extension.
- Avoid uncaught exceptions – get a clear `ResultData` or `ResultError`.
- Optional `onSuccess` and `onError` callbacks, when, map, andThen methods.
- With ResultOr simply call your functions in bloc/store/etc, or anywhere else, wrapped in ResultOr()
- Better than other similar solutions, because you don't need to return special data from every function and support corresponding logic. You only wrap at the end in one place 

---

## Installation

```yaml
dependencies:
  result_or: ^0.8.7
```

## Usage

```dart
    
    // Simple function example
    var result = ResultOr(someFunction);
    // With extensions: var result = someFunction.resultOr();
    
    // Callback function example
    ResultOr(someFunction,
        onSuccess: (data) {
            print(data);
        },
        onError: (error) {
          print(error.message);
        }
    );
    // With extensions: var result = someFunction.resultOr(onSuccess, onError);
    
    // if example
    if (result case ResultWithData())  {
      print(result.data);
    } else if (result case ResultWithError()) {
      print(result.error.message);
    }
    
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

## More examples

```dart
    // Future function example + switch/case
    var result2 = await ResultOr.async(someFutureFunction);
    
    switch (result2) {
      case ResultWithData(:final data):
        print(data);
      case ResultWithError(:final error):
        print(error.message);
    }
    
    // Parametrized function example
    var result3 = ResultOr(() => someFunctionWithParam(2));
    
    // Separate callbacks, same for onError
    result3.onSuccess((data) => print(data));
    
    // Parametrized future function example
    var result4 = await ResultOr.async(() => someFutureFunctionWithParam("Param"));
    
    // When example
    result3.when(
      (data) => print(data), 
      (error) => print(error)
    );
    
    // Using extensions and async with params
    var result6 = await (() => someFutureFunctionWithParam("param")).resultOr();
    
    if (result6 case ResultWithData())  {
      print(result6.data);
    } else if (result6 case ResultWithError()) {
      print(result6.error.message);
    }

```

## Handy getters and extensions

```dart
    final result = ResultOr(() => 42);
    
    // Just simple getter fields
    if (result.isSuccess) {
      ...
    } else if (result.isError) {
      ...
    }

    final result = ResultOr(() => throw Exception("failure"));
    
    // Fields to get data/error or null, convenient to use in some rare cases
    print("Data: ${result.dataOrNull}"); // null
    print("Error: ${result.errorOrNull?.message}"); // "failure"

    /// Maps the successful result data to a new type using [transform].
    ///
    /// - If this is a [ResultData], applies [transform] to the data and wraps in a new ResultData.
    /// - If this is a [ResultError], returns the same error with the new type.
    final result = ResultOr(() => 21)
        .map((n) => "${n * 2}"); // ResultData<int> → ResultData<str>
    
    if (result case ResultWithData()) {
      print("Mapped result: ${result.data}"); // 42
    }

    /// Transforms the error inside [ResultError] using [transform].
    ///
    /// - If this is a [ResultError], applies [transform] to its error and returns new ResultError.
    /// - If this is a [ResultData], returns the same success unchanged.
    final result = ResultOr(() {
      throw TestNonFatalError("Original failure");
    }).mapError((err) => TestNonFatalError("Wrapped: ${err.message}"));
    
    if (result case ResultWithError()) {
      print(result.error.message); // Wrapped: Original failure
    }

    /// Chains another ResultOr-producing function if this result is successful.
    ///
    /// - If this is a [ResultData], applies [transform] to its data and returns the result.
    /// - If this is a [ResultError], returns the same error wrapped in a new ResultError of type R.
    final result = ResultOr(() => 5).andThen((value) {
        if (value > 0) {
          return ResultData<String>(data: 'Valid: $value');
        } else {
          return ResultError<String>(error: TestNonFatalError('Invalid'));
        }
    });
    
    if (result case ResultWithData()) {
      print(result.data); // 'Valid: 5'
    }
```