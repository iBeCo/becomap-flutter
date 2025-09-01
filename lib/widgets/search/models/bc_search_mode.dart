/// **BCSearchMode** - Defines the search widget operation modes.
///
/// This enum determines whether the search widget operates in single search mode
/// or dual-field navigation mode with origin and destination inputs.
///
/// **Usage Example:**
/// ```dart
/// // Single search mode
/// BCLocationSearchWidget(
///   mode: BCSearchMode.single,
///   onLocationSelected: (location, fieldType) {
///     print('Selected: ${location.name}');
///   },
/// )
///
/// // Navigation mode with origin/destination
/// BCLocationSearchWidget(
///   mode: BCSearchMode.navigation,
///   onLocationSelected: (location, fieldType) {
///     if (fieldType == BCSearchFieldType.origin) {
///       print('Origin: ${location.name}');
///     } else {
///       print('Destination: ${location.name}');
///     }
///   },
/// )
/// ```
enum BCSearchMode {
  /// **Single search mode** - Shows one search field with "Where to go?" placeholder.
  /// 
  /// This is the default mode for basic location search functionality.
  /// Users can search for and select a single destination location.
  single,

  /// **Navigation mode** - Shows dual search fields for origin and destination.
  /// 
  /// This mode enables route planning with separate origin and destination
  /// search fields. Users can search for both starting point and destination.
  navigation,
}

/// Extension methods for BCSearchMode enum.
extension BCSearchModeExtension on BCSearchMode {
  /// Returns a human-readable description of the search mode.
  String get description {
    switch (this) {
      case BCSearchMode.single:
        return 'Single location search';
      case BCSearchMode.navigation:
        return 'Navigation with origin and destination';
    }
  }

  /// Returns true if this mode supports dual search fields.
  bool get isDualField {
    return this == BCSearchMode.navigation;
  }

  /// Returns true if this mode supports single search field.
  bool get isSingleField {
    return this == BCSearchMode.single;
  }
}
