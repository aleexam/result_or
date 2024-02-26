part of "core.dart";

/// Class that represents successful data returned from some function
final class ResultData<T> extends ResultOr<T> {
  T data;

  ResultData({required this.data});
}

/// Class that represents error thrown from some function and caught to error object
final class ResultError<T> extends ResultOr<T> {
  BaseResultError error;

  ResultError({required this.error});
}