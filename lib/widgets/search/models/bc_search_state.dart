import 'package:becomap/becomap.dart';
import 'bc_search_field_type.dart';

/// **BCSearchState** - Represents the current state of a search operation.
///
/// This class encapsulates all information about an ongoing or completed search,
/// including the query, results, loading status, and any errors that occurred.
///
/// **Usage Example:**
/// ```dart
/// // Create initial idle state
/// final state = BCSearchState.idle(BCSearchFieldType.destination);
///
/// // Update to loading state
/// final loadingState = state.copyWith(
///   isLoading: true,
///   query: 'coffee shop',
/// );
///
/// // Update with results
/// final resultsState = loadingState.copyWith(
///   isLoading: false,
///   results: searchResults,
/// );
/// ```
class BCSearchState {
  /// **Field type** this state belongs to (origin or destination).
  final BCSearchFieldType fieldType;

  /// **Current search query** entered by the user.
  final String query;

  /// **Search results** returned from the search operation.
  final List<BCLocation> results;

  /// **Loading indicator** - true when search is in progress.
  final bool isLoading;

  /// **Error message** if search failed, null if no error.
  final String? error;

  /// **Has searched** - true if at least one search has been performed.
  final bool hasSearched;

  /// Creates a new BCSearchState instance.
  const BCSearchState({
    required this.fieldType,
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.hasSearched = false,
  });

  /// Creates an idle search state for the specified field type.
  ///
  /// **Parameters:**
  /// - [fieldType] The search field type this state represents
  ///
  /// **Returns:**
  /// - BCSearchState in idle state with empty query and results
  BCSearchState.idle(this.fieldType)
      : query = '',
        results = const [],
        isLoading = false,
        error = null,
        hasSearched = false;

  /// Creates a loading search state with the specified query.
  ///
  /// **Parameters:**
  /// - [fieldType] The search field type this state represents
  /// - [query] The search query being processed
  ///
  /// **Returns:**
  /// - BCSearchState in loading state
  BCSearchState.loading(this.fieldType, this.query)
      : results = const [],
        isLoading = true,
        error = null,
        hasSearched = true;

  /// Creates a success search state with results.
  ///
  /// **Parameters:**
  /// - [fieldType] The search field type this state represents
  /// - [query] The search query that was processed
  /// - [results] The search results returned
  ///
  /// **Returns:**
  /// - BCSearchState with successful results
  BCSearchState.success(this.fieldType, this.query, this.results)
      : isLoading = false,
        error = null,
        hasSearched = true;

  /// Creates an error search state with error message.
  ///
  /// **Parameters:**
  /// - [fieldType] The search field type this state represents
  /// - [query] The search query that failed
  /// - [error] The error message describing what went wrong
  ///
  /// **Returns:**
  /// - BCSearchState with error information
  BCSearchState.error(this.fieldType, this.query, this.error)
      : results = const [],
        isLoading = false,
        hasSearched = true;

  /// Creates a copy of this state with optionally updated values.
  ///
  /// **Parameters:**
  /// - [fieldType] New field type (optional)
  /// - [query] New search query (optional)
  /// - [results] New search results (optional)
  /// - [isLoading] New loading status (optional)
  /// - [error] New error message (optional)
  /// - [hasSearched] New searched status (optional)
  ///
  /// **Returns:**
  /// - New BCSearchState instance with updated values
  BCSearchState copyWith({
    BCSearchFieldType? fieldType,
    String? query,
    List<BCLocation>? results,
    bool? isLoading,
    String? error,
    bool? hasSearched,
  }) {
    return BCSearchState(
      fieldType: fieldType ?? this.fieldType,
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }

  /// Returns true if this state represents a successful search with results.
  bool get hasResults => results.isNotEmpty && !isLoading && error == null;

  /// Returns true if this state represents an empty search result.
  bool get isEmpty => results.isEmpty && !isLoading && error == null && hasSearched;

  /// Returns true if this state represents an error condition.
  bool get hasError => error != null;

  /// Returns true if this state is in idle condition (no search performed).
  bool get isIdle => !hasSearched && !isLoading && error == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BCSearchState &&
        other.fieldType == fieldType &&
        other.query == query &&
        other.results == results &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.hasSearched == hasSearched;
  }

  @override
  int get hashCode {
    return Object.hash(
      fieldType,
      query,
      results,
      isLoading,
      error,
      hasSearched,
    );
  }

  @override
  String toString() {
    return 'BCSearchState('
        'fieldType: $fieldType, '
        'query: "$query", '
        'results: ${results.length} items, '
        'isLoading: $isLoading, '
        'error: $error, '
        'hasSearched: $hasSearched'
        ')';
  }
}
