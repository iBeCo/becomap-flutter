import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:becomap/becomap.dart';

import '../models/bc_search_mode.dart';
import '../models/bc_search_field_type.dart';
import '../models/bc_search_state.dart';
import 'bc_search_debouncer.dart';

/// **BCSearchController** - Manages search business logic and state transitions.
///
/// This controller handles search validation, state management, caching, and
/// coordinates between the UI layer and search operations. It maintains separate
/// states for origin and destination fields in navigation mode.
///
/// **Usage Example:**
/// ```dart
/// final controller = BCSearchController(
///   mode: BCSearchMode.navigation,
///   onSearchRequested: (query, fieldType) async {
///     // Perform actual search using SDK
///     final locations = await mapView.searchForLocations(query);
///     return locations;
///   },
/// );
///
/// // Listen to state changes
/// controller.addListener(() {
///   setState(() {
///     // Update UI based on controller state
///   });
/// });
/// ```
class BCSearchController extends ChangeNotifier {
  /// **Search mode** - Single or navigation mode.
  BCSearchMode _mode;

  /// **Search states** - Separate states for origin and destination fields.
  final Map<BCSearchFieldType, BCSearchState> _states = {};

  /// **Search cache** - Caches recent search results to avoid duplicate requests.
  final Map<String, List<BCLocation>> _searchCache = {};

  /// **Debouncer** - Prevents excessive search requests.
  final BCSearchDebouncer _debouncer;

  /// **Search callback** - Function to perform actual search operations.
  final Future<List<BCLocation>> Function(
    String query,
    BCSearchFieldType fieldType,
  )?
  onSearchRequested;

  /// **State change callback** - Notified when search state changes.
  final void Function(BCSearchState state, BCSearchFieldType fieldType)?
  onStateChanged;

  /// **Cache expiry duration** - How long to keep cached results.
  final Duration cacheExpiry;

  /// **Cache timestamps** - Tracks when cache entries were created.
  final Map<String, DateTime> _cacheTimestamps = {};

  /// Creates a new BCSearchController instance.
  ///
  /// **Parameters:**
  /// - [mode] Search mode (single or navigation)
  /// - [onSearchRequested] Callback to perform actual search operations
  /// - [onStateChanged] Callback for state change notifications
  /// - [debounceDelay] Delay for debouncing search input
  /// - [cacheExpiry] Duration to keep cached search results
  BCSearchController({
    BCSearchMode mode = BCSearchMode.single,
    this.onSearchRequested,
    this.onStateChanged,
    Duration debounceDelay = const Duration(milliseconds: 500),
    this.cacheExpiry = const Duration(minutes: 5),
  }) : _mode = mode,
       _debouncer = BCSearchDebouncer(delay: debounceDelay) {
    _initializeStates();
  }

  /// **Current search mode** - Single or navigation mode.
  BCSearchMode get mode => _mode;

  /// **Origin state** - Search state for origin field (navigation mode only).
  BCSearchState get originState =>
      _states[BCSearchFieldType.origin] ??
      BCSearchState.idle(BCSearchFieldType.origin);

  /// **Destination state** - Search state for destination field.
  BCSearchState get destinationState =>
      _states[BCSearchFieldType.destination] ??
      BCSearchState.idle(BCSearchFieldType.destination);

  /// **Is searching** - True if any field is currently performing a search.
  bool get isSearching => _states.values.any((state) => state.isLoading);

  /// **Has any results** - True if any field has search results.
  bool get hasAnyResults => _states.values.any((state) => state.hasResults);

  /// **Has any errors** - True if any field has search errors.
  bool get hasAnyErrors => _states.values.any((state) => state.hasError);

  /// Initializes search states based on current mode.
  void _initializeStates() {
    _states.clear();

    // Always initialize destination state
    _states[BCSearchFieldType.destination] = BCSearchState.idle(
      BCSearchFieldType.destination,
    );

    // Initialize origin state only in navigation mode
    if (_mode == BCSearchMode.navigation) {
      _states[BCSearchFieldType.origin] = BCSearchState.idle(
        BCSearchFieldType.origin,
      );
    }
  }

  /// Switches the search mode and reinitializes states.
  ///
  /// **Parameters:**
  /// - [newMode] The new search mode to switch to
  ///
  /// **Example:**
  /// ```dart
  /// // Switch from single to navigation mode
  /// controller.switchMode(BCSearchMode.navigation);
  /// ```
  void switchMode(BCSearchMode newMode) {
    if (_mode == newMode) return;

    _mode = newMode;
    _initializeStates();
    notifyListeners();
  }

  /// Performs a search for the specified field type.
  ///
  /// This method handles debouncing, caching, validation, and state management
  /// for search operations. It automatically updates the search state and
  /// notifies listeners of changes.
  ///
  /// **Parameters:**
  /// - [query] The search query string
  /// - [fieldType] The field type to search for
  ///
  /// **Example:**
  /// ```dart
  /// // Perform search for destination
  /// controller.performSearch('coffee shop', BCSearchFieldType.destination);
  /// ```
  void performSearch(String query, BCSearchFieldType fieldType) {
    // Validate input
    if (!_validateSearchInput(query, fieldType)) {
      return;
    }

    // Check cache first
    final cachedResults = _getCachedResults(query);
    if (cachedResults != null) {
      _updateState(BCSearchState.success(fieldType, query, cachedResults));
      return;
    }

    // Update to loading state
    _updateState(BCSearchState.loading(fieldType, query));

    // Debounce the actual search operation
    _debouncer.debounce(() {
      _executeSearch(query, fieldType);
    });
  }

  /// Executes the actual search operation.
  Future<void> _executeSearch(String query, BCSearchFieldType fieldType) async {
    try {
      if (onSearchRequested == null) {
        _updateState(
          BCSearchState.error(
            fieldType,
            query,
            'Search functionality not available',
          ),
        );
        return;
      }

      final results = await onSearchRequested!(query, fieldType);

      // Cache the results
      _cacheResults(query, results);

      // Update state with results
      _updateState(BCSearchState.success(fieldType, query, results));
    } catch (error) {
      _updateState(
        BCSearchState.error(
          fieldType,
          query,
          'Search failed: ${error.toString()}',
        ),
      );
    }
  }

  /// Validates search input parameters.
  bool _validateSearchInput(String query, BCSearchFieldType fieldType) {
    // Check if query is empty
    if (query.trim().isEmpty) {
      clearSearch(fieldType);
      return false;
    }

    // Check query length (max 100 characters as per WebView API)
    if (query.length > 100) {
      _updateState(
        BCSearchState.error(
          fieldType,
          query,
          'Search query too long (max 100 characters)',
        ),
      );
      return false;
    }

    // Check if field type is valid for current mode
    if (fieldType == BCSearchFieldType.origin &&
        _mode != BCSearchMode.navigation) {
      return false;
    }

    return true;
  }

  /// Updates the search state and notifies listeners.
  void _updateState(BCSearchState newState) {
    _states[newState.fieldType] = newState;
    onStateChanged?.call(newState, newState.fieldType);
    notifyListeners();
  }

  /// Gets cached search results if available and not expired.
  List<BCLocation>? _getCachedResults(String query) {
    final cacheKey = query.toLowerCase().trim();
    final timestamp = _cacheTimestamps[cacheKey];

    if (timestamp == null) return null;

    // Check if cache has expired
    if (DateTime.now().difference(timestamp) > cacheExpiry) {
      _searchCache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
      return null;
    }

    return _searchCache[cacheKey];
  }

  /// Caches search results with timestamp.
  void _cacheResults(String query, List<BCLocation> results) {
    final cacheKey = query.toLowerCase().trim();
    _searchCache[cacheKey] = results;
    _cacheTimestamps[cacheKey] = DateTime.now();

    // Limit cache size to prevent memory issues
    if (_searchCache.length > 50) {
      _clearOldestCacheEntry();
    }
  }

  /// Removes the oldest cache entry to manage memory.
  void _clearOldestCacheEntry() {
    if (_cacheTimestamps.isEmpty) return;

    final oldestKey = _cacheTimestamps.entries
        .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
        .key;

    _searchCache.remove(oldestKey);
    _cacheTimestamps.remove(oldestKey);
  }

  /// Clears search results for the specified field type.
  ///
  /// **Parameters:**
  /// - [fieldType] The field type to clear
  ///
  /// **Example:**
  /// ```dart
  /// // Clear destination search
  /// controller.clearSearch(BCSearchFieldType.destination);
  /// ```
  void clearSearch(BCSearchFieldType fieldType) {
    _debouncer.cancel();
    _updateState(BCSearchState.idle(fieldType));
  }

  /// Clears all search results and resets to idle state.
  ///
  /// **Example:**
  /// ```dart
  /// // Clear all searches
  /// controller.clearAllSearches();
  /// ```
  void clearAllSearches() {
    _debouncer.cancel();
    for (final fieldType in _states.keys) {
      _updateState(BCSearchState.idle(fieldType));
    }
  }

  /// Clears the search cache.
  ///
  /// **Example:**
  /// ```dart
  /// // Clear cached results
  /// controller.clearCache();
  /// ```
  void clearCache() {
    _searchCache.clear();
    _cacheTimestamps.clear();
  }

  /// Gets the search state for the specified field type.
  ///
  /// **Parameters:**
  /// - [fieldType] The field type to get state for
  ///
  /// **Returns:**
  /// - BCSearchState for the specified field type
  BCSearchState getStateForField(BCSearchFieldType fieldType) {
    return _states[fieldType] ?? BCSearchState.idle(fieldType);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  String toString() {
    return 'BCSearchController('
        'mode: $_mode, '
        'isSearching: $isSearching, '
        'hasResults: $hasAnyResults, '
        'cacheSize: ${_searchCache.length}'
        ')';
  }
}
