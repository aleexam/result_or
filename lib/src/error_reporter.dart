part of 'core.dart';

/// Manages reporting of errors caught via `ResultOr`.
/// Allows plugging in a custom handler or enabling the default
/// debug reporter that tags and rethrows errors into the current Zone.
class ResultOrHandledErrorReporter {

  /// Function called whenever `ResultOr` intercepts an exception.
  /// By default, it’s a no-op.
  static Function(Object e, StackTrace s) _reportCaughtError = (e, s) {};

  /// Sets a custom reporter function that will be invoked on each caught error.
  ///
  /// [reporter] — a callback receiving the error object and its stack trace.
  static void setCustomHandledErrorReporter(void Function(Object e, StackTrace s) reporter) {
    _reportCaughtError = reporter;
  }

  /// Enables the default debug reporter.
  ///
  /// Caught errors will be labeled with `"Caught by ResultOr"`
  /// and pass into the current Zone, without interrupting code.
  /// Will break tests while activated
  static void setDefaultDebugErrorReporter() {
    _reportCaughtError = (e, s) {
      Zone.current.handleUncaughtError(e, _ResultOrLabeledStackTrace("Caught by ResultOr", s));
    };
  }
}

class _ResultOrLabeledStackTrace implements StackTrace {
  final String label;
  final StackTrace original;

  _ResultOrLabeledStackTrace(this.label, this.original);

  @override
  String toString() =>
      '$label\n'
          '${original.toString()}';
}