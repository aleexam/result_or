part of "result_or.dart";

/// Class that represents successful data returned from some function
class ResultWithData<T> extends ResultOr<T> {
  T data;

  ResultWithData({required this.data});
}

/// Class that represents error thrown from some function and caught to error object
class ResultWithError<T> extends ResultOr<T> {
  BaseResultError error;

  ResultWithError({required this.error});
}