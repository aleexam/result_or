part of "result_or.dart";

/// Class that represents successful data returned from some function
class ResultData<T> extends ResultOr<T> {
  T data;

  ResultData({required this.data});
}

/// Class that represents error thrown from some function and caught to error object
class ResultError<T> extends ResultOr<T> {
  BaseResultError error;

  ResultError({required this.error});
}