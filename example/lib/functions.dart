
import 'dart:math';

import 'package:result_or/result_or.dart';

/// Simply create function which return desired result or throws exceptions/errors.
/// All exceptions will be handled by Either wrappers [ResultOr.fromFunction], [ResultOr.fromFuture], etc.
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

String someFunctionWithParam(int param) {
  var isSuccess = Random().nextBool();

  if (isSuccess) {
    return "success payload";
  } else {
    throw Exception("error");
  }
}

Future<String> someFutureFunction() async {
  var isSuccess = Random().nextBool();

  await Future.delayed(const Duration(seconds: 3));

  if (isSuccess) {
    return "success payload";
  } else {
    throw Exception("error");
  }
}

Future<String> someFutureFunctionWithParam(String param) async {
  var isSuccess = Random().nextBool();

  await Future.delayed(const Duration(seconds: 3));

  if (isSuccess) {
    return "success payload";
  } else {
    throw Exception("error");
  }
}

/// Example of function returning result after processing ResultOr wrapped function.
/// Thanks to sealed class make this available to be null safety
Future<String> returnResultOrExampleFunction() async {
  var result = await ResultOr.fromFuture(someFutureFunction);

  switch (result) {
    case ResultData():
      return result.data;
    case ResultError():
      return result.error.message;
  }
}
