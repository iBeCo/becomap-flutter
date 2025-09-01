import 'package:flutter/material.dart';
import 'package:becomap/becomap.dart';

import 'models/bc_search_mode.dart';
import 'models/bc_search_field_type.dart';
import 'models/bc_search_state.dart';
import 'controllers/bc_search_controller.dart';
import 'bc_search_field.dart';
import 'bc_search_results_list.dart';
import 'bc_search_empty_state.dart';
import 'bc_search_loading_state.dart';

/// **BCLocationSearchWidget** - Main search widget coordinating all search components.
///
/// This widget provides a complete location search interface with support for both
/// single location search and dual-field navigation mode. It manages search state,
/// coordinates between components, and handles user interactions.
///
/// **Usage Example:**
/// ```dart
/// BCLocationSearchWidget(
///   mode: BCSearchMode.single,
///   onLocationSelected: (location, fieldType) {
///     print('Selected: ${location.name}');
///     // Handle location selection
///   },
///   onSearchRequested: (query, fieldType) async {
///     // Perform search using SDK or API
///     return await searchLocations(query);
///   },
/// )
/// ```
class BCLocationSearchWidget extends StatefulWidget {
  /// **Search mode** - Single or navigation mode.
  final BCSearchMode mode;

  /// **Location selection callback** - Called when a location is selected.
  final void Function(BCLocation location, BCSearchFieldType fieldType)?
  onLocationSelected;

  /// **Search request callback** - Called to perform actual search operations.
  final Future<List<BCLocation>> Function(
    String query,
    BCSearchFieldType fieldType,
  )?
  onSearchRequested;

  /// **Search mode change callback** - Called when search mode changes.
  final void Function(BCSearchMode mode)? onSearchModeChanged;

  /// **Search state change callback** - Called when search state changes.
  final void Function(BCSearchState state, BCSearchFieldType fieldType)?
  onSearchStateChanged;

  /// **Search cancel callback** - Called when search widget is canceled/closed.
  final VoidCallback? onSearchCanceled;

  /// **Initial origin value** - Pre-populated origin field text.
  final String? initialOriginValue;

  /// **Initial destination value** - Pre-populated destination field text.
  final String? initialDestinationValue;

  /// **Debounce delay** - Delay for debouncing search input.
  final Duration debounceDelay;

  /// **Show mode toggle** - Whether to show mode toggle button.
  final bool showModeToggle;

  /// **Maximum results height** - Maximum height for results list.
  final double? maxResultsHeight;

  /// **Enable search suggestions** - Whether to show search suggestions.
  final bool enableSuggestions;

  /// **Search suggestions** - List of suggested search terms.
  final List<String> suggestions;

  /// **Background color** - Background color of the search widget.
  final Color? backgroundColor;

  /// **Padding** - Internal padding around the search widget.
  final EdgeInsetsGeometry? padding;

  /// Creates a new BCLocationSearchWidget instance.
  ///
  /// **Parameters:**
  /// - [mode] Search mode (single or navigation)
  /// - [onLocationSelected] Callback for location selection
  /// - [onSearchRequested] Callback for search operations
  /// - [onSearchModeChanged] Callback for mode changes
  /// - [onSearchStateChanged] Callback for state changes
  /// - [initialOriginValue] Initial origin field text
  /// - [initialDestinationValue] Initial destination field text
  /// - [debounceDelay] Debounce delay (default: 500ms)
  /// - [showModeToggle] Whether to show mode toggle (default: false)
  /// - [maxResultsHeight] Maximum results height
  /// - [enableSuggestions] Whether to enable suggestions (default: true)
  /// - [suggestions] List of search suggestions
  /// - [backgroundColor] Background color
  /// - [padding] Internal padding
  const BCLocationSearchWidget({
    super.key,
    this.mode = BCSearchMode.single,
    this.onLocationSelected,
    this.onSearchRequested,
    this.onSearchModeChanged,
    this.onSearchStateChanged,
    this.onSearchCanceled,
    this.initialOriginValue,
    this.initialDestinationValue,
    this.debounceDelay = const Duration(milliseconds: 500),
    this.showModeToggle = false,
    this.maxResultsHeight,
    this.enableSuggestions = true,
    this.suggestions = const [
      'restaurant',
      'coffee',
      'restroom',
      'parking',
      'store',
    ],
    this.backgroundColor,
    this.padding,
  });

  @override
  State<BCLocationSearchWidget> createState() => _BCLocationSearchWidgetState();
}

class _BCLocationSearchWidgetState extends State<BCLocationSearchWidget> {
  late BCSearchController _searchController;
  final Map<BCSearchFieldType, String> _fieldValues = {};

  BCSearchFieldType? _activeField;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();

    _initializeController();
    _initializeFieldValues();
  }

  void _initializeFieldValues() {
    _fieldValues[BCSearchFieldType.destination] =
        widget.initialDestinationValue ?? '';

    if (widget.mode == BCSearchMode.navigation) {
      _fieldValues[BCSearchFieldType.origin] = widget.initialOriginValue ?? '';
    }
  }

  @override
  void didUpdateWidget(BCLocationSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller if mode changed
    if (widget.mode != oldWidget.mode) {
      _searchController.switchMode(widget.mode);
      widget.onSearchModeChanged?.call(widget.mode);
    }

    // Update field values if initial values changed
    if (widget.initialOriginValue != oldWidget.initialOriginValue) {
      _fieldValues[BCSearchFieldType.origin] = widget.initialOriginValue ?? '';
    }

    if (widget.initialDestinationValue != oldWidget.initialDestinationValue) {
      _fieldValues[BCSearchFieldType.destination] =
          widget.initialDestinationValue ?? '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeController() {
    _searchController = BCSearchController(
      mode: widget.mode,
      onSearchRequested: widget.onSearchRequested,
      onStateChanged: (state, fieldType) {
        widget.onSearchStateChanged?.call(state, fieldType);
        setState(() {
          _showResults =
              state.hasResults ||
              state.isLoading ||
              state.hasError ||
              state.isEmpty;
        });
      },
      debounceDelay: widget.debounceDelay,
    );

    _searchController.addListener(() {
      setState(() {});
    });
  }

  void _onSearchChanged(String query, BCSearchFieldType fieldType) {
    if (query.trim().isEmpty) {
      _searchController.clearSearch(fieldType);
      setState(() {
        _showResults = false;
      });
    } else {
      _searchController.performSearch(query, fieldType);
      setState(() {
        _showResults = true;
      });
    }
  }

  void _onLocationSelected(BCLocation location, BCSearchFieldType fieldType) {
    // Update field value with selected location
    _fieldValues[fieldType] = location.name ?? '';

    // Clear search results
    _searchController.clearSearch(fieldType);

    // Hide results
    setState(() {
      _showResults = false;
    });

    // Notify parent
    widget.onLocationSelected?.call(location, fieldType);
  }

  void _onFieldCleared(BCSearchFieldType fieldType) {
    _fieldValues[fieldType] = '';
    _searchController.clearSearch(fieldType);
    setState(() {
      _showResults = false;
    });
  }

  void _onSuggestionTapped(String suggestion) {
    if (_activeField != null) {
      // Fill the field value with the suggestion
      _fieldValues[_activeField!] = suggestion;

      // Trigger search with the suggestion
      _onSearchChanged(suggestion, _activeField!);

      // Trigger rebuild to update the field
      setState(() {});
    }
  }

  /// Determines if the origin field should auto-focus in navigation mode
  bool _shouldAutoFocusOrigin() {
    // Auto-focus origin field if:
    // 1. We're in navigation mode
    // 2. Origin field is empty
    // 3. Destination field has a value (pre-filled from navigation)
    return widget.mode == BCSearchMode.navigation &&
        (_fieldValues[BCSearchFieldType.origin]?.isEmpty ?? true) &&
        (_fieldValues[BCSearchFieldType.destination]?.isNotEmpty ?? false);
  }

  /// Determines if the destination field should auto-focus
  bool _shouldAutoFocusDestination() {
    // Auto-focus destination field if:
    // 1. We're in navigation mode and destination is empty, OR
    // 2. We're in single mode (default behavior)
    if (widget.mode == BCSearchMode.navigation) {
      return (_fieldValues[BCSearchFieldType.destination]?.isEmpty ?? true);
    } else {
      return true; // Single mode always focuses destination
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSearchFields(),
          if (_showResults && _activeField != null) ...[
            const SizedBox(height: 16),
            _buildSearchResults(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchFields() {
    if (widget.mode == BCSearchMode.navigation) {
      return Column(
        children: [
          // Origin field
          BCSearchField(
            key: ValueKey('origin_${_fieldValues[BCSearchFieldType.origin]}'),
            fieldType: BCSearchFieldType.origin,
            initialValue: _fieldValues[BCSearchFieldType.origin],
            onChanged: (query) =>
                _onSearchChanged(query, BCSearchFieldType.origin),
            onClear: () => _onFieldCleared(BCSearchFieldType.origin),
            onFocusChanged: (hasFocus) {
              if (hasFocus) {
                setState(() {
                  _activeField = BCSearchFieldType.origin;
                });
              }
            },
            autofocus: _shouldAutoFocusOrigin(),
          ),

          const SizedBox(height: 16),

          // Destination field
          BCSearchField(
            key: ValueKey(
              'destination_${_fieldValues[BCSearchFieldType.destination]}',
            ),
            fieldType: BCSearchFieldType.destination,
            initialValue: _fieldValues[BCSearchFieldType.destination],
            onChanged: (query) =>
                _onSearchChanged(query, BCSearchFieldType.destination),
            onClear: () => _onFieldCleared(BCSearchFieldType.destination),
            onFocusChanged: (hasFocus) {
              if (hasFocus) {
                setState(() {
                  _activeField = BCSearchFieldType.destination;
                });
              }
            },
            autofocus: _shouldAutoFocusDestination(),
          ),
        ],
      );
    } else {
      // Single mode - destination field only
      return BCSearchField(
        key: ValueKey(
          'destination_${_fieldValues[BCSearchFieldType.destination]}',
        ),
        fieldType: BCSearchFieldType.destination,
        initialValue: _fieldValues[BCSearchFieldType.destination],
        onChanged: (query) =>
            _onSearchChanged(query, BCSearchFieldType.destination),
        onClear: () => _onFieldCleared(BCSearchFieldType.destination),
        onFocusChanged: (hasFocus) {
          if (hasFocus) {
            setState(() {
              _activeField = BCSearchFieldType.destination;
            });
          }
        },
        autofocus: _shouldAutoFocusDestination(),
      );
    }
  }

  Widget _buildSearchResults() {
    if (_activeField == null) return const SizedBox.shrink();

    final state = _searchController.getStateForField(_activeField!);

    // Show loading state
    if (state.isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: BCSearchLoadingState(
          message: 'Searching for locations...',
          compact: true,
          padding: const EdgeInsets.all(16),
        ),
      );
    }

    // Show error state
    if (state.hasError) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.error ?? 'Search failed',
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    // Show empty state with suggestions
    if (state.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: BCSearchEmptyState(
          query: state.query,
          compact: true,
          showSuggestions: widget.enableSuggestions,
          suggestions: widget.suggestions,
          onSuggestionTapped: _onSuggestionTapped,
          padding: const EdgeInsets.all(16),
        ),
      );
    }

    // Show results
    if (state.hasResults) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: BCSearchResultsList(
          results: state.results,
          fieldType: _activeField!,
          onLocationSelected: _onLocationSelected,
          maxHeight: widget.maxResultsHeight,
          searchQuery: state.query,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
