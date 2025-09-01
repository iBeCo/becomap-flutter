import 'dart:async';

/// **BCSearchDebouncer** - Utility for debouncing search input to prevent excessive API calls.
///
/// This class implements a debouncing mechanism that delays the execution of search
/// operations until the user has stopped typing for a specified duration. This prevents
/// excessive search requests and improves performance.
///
/// **Usage Example:**
/// ```dart
/// final debouncer = BCSearchDebouncer(
///   delay: Duration(milliseconds: 500),
/// );
///
/// // In text field onChange
/// void onSearchChanged(String query) {
///   debouncer.debounce(() {
///     performSearch(query);
///   });
/// }
///
/// // Don't forget to dispose
/// @override
/// void dispose() {
///   debouncer.dispose();
///   super.dispose();
/// }
/// ```
class BCSearchDebouncer {
  /// **Debounce delay** - Duration to wait before executing the action.
  final Duration delay;

  /// **Timer instance** for managing the debounce delay.
  Timer? _timer;

  /// Creates a new BCSearchDebouncer instance.
  ///
  /// **Parameters:**
  /// - [delay] Duration to wait before executing debounced actions
  ///
  /// **Example:**
  /// ```dart
  /// // 500ms debounce delay (recommended for search)
  /// final debouncer = BCSearchDebouncer(
  ///   delay: Duration(milliseconds: 500),
  /// );
  /// ```
  BCSearchDebouncer({
    this.delay = const Duration(milliseconds: 500),
  });

  /// Debounces the execution of the provided action.
  ///
  /// If this method is called again before the delay expires, the previous
  /// timer is cancelled and a new one is started. This ensures that the
  /// action is only executed after the user has stopped triggering events
  /// for the specified delay duration.
  ///
  /// **Parameters:**
  /// - [action] The function to execute after the debounce delay
  ///
  /// **Example:**
  /// ```dart
  /// debouncer.debounce(() {
  ///   print('This will only execute after user stops typing');
  ///   performSearch(currentQuery);
  /// });
  /// ```
  void debounce(VoidCallback action) {
    // Cancel any existing timer
    _timer?.cancel();

    // Start a new timer with the specified delay
    _timer = Timer(delay, action);
  }

  /// Immediately executes the provided action and cancels any pending debounced actions.
  ///
  /// This method is useful when you need to force immediate execution,
  /// such as when the user presses enter or clicks a search button.
  ///
  /// **Parameters:**
  /// - [action] The function to execute immediately
  ///
  /// **Example:**
  /// ```dart
  /// // User pressed enter - execute search immediately
  /// debouncer.executeImmediately(() {
  ///   performSearch(currentQuery);
  /// });
  /// ```
  void executeImmediately(VoidCallback action) {
    // Cancel any pending debounced action
    _timer?.cancel();
    
    // Execute the action immediately
    action();
  }

  /// Cancels any pending debounced actions.
  ///
  /// This method stops the current timer without executing the pending action.
  /// Useful for cancelling search operations when the widget is disposed or
  /// when the user clears the search field.
  ///
  /// **Example:**
  /// ```dart
  /// // User cleared the search field - cancel pending search
  /// debouncer.cancel();
  /// ```
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Returns true if there is a pending debounced action.
  ///
  /// This can be used to show loading indicators or disable UI elements
  /// while a debounced action is waiting to execute.
  ///
  /// **Returns:**
  /// - true if an action is pending execution, false otherwise
  ///
  /// **Example:**
  /// ```dart
  /// if (debouncer.isPending) {
  ///   // Show loading indicator
  ///   return CircularProgressIndicator();
  /// }
  /// ```
  bool get isPending => _timer != null && _timer!.isActive;

  /// Returns the remaining time until the pending action executes.
  ///
  /// **Returns:**
  /// - Duration remaining until execution, or Duration.zero if no action is pending
  ///
  /// **Example:**
  /// ```dart
  /// final remaining = debouncer.remainingTime;
  /// print('Search will execute in ${remaining.inMilliseconds}ms');
  /// ```
  Duration get remainingTime {
    if (_timer == null || !_timer!.isActive) {
      return Duration.zero;
    }
    // Note: Timer doesn't provide remaining time directly,
    // so we return the original delay as an approximation
    return delay;
  }

  /// Disposes of the debouncer and cancels any pending actions.
  ///
  /// This method should be called when the debouncer is no longer needed,
  /// typically in the dispose method of a StatefulWidget.
  ///
  /// **Example:**
  /// ```dart
  /// @override
  /// void dispose() {
  ///   debouncer.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  String toString() {
    return 'BCSearchDebouncer('
        'delay: ${delay.inMilliseconds}ms, '
        'isPending: $isPending'
        ')';
  }
}

/// **VoidCallback** type alias for functions that take no parameters and return void.
typedef VoidCallback = void Function();
