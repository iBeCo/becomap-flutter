/// **BCSearchFieldType** - Identifies different search input fields.
///
/// This enum distinguishes between origin and destination search fields
/// in navigation mode, enabling proper callback handling and state management.
///
/// **Usage Example:**
/// ```dart
/// // Handle location selection based on field type
/// void onLocationSelected(BCLocation location, BCSearchFieldType fieldType) {
///   switch (fieldType) {
///     case BCSearchFieldType.origin:
///       setState(() {
///         _originLocation = location;
///       });
///       break;
///     case BCSearchFieldType.destination:
///       setState(() {
///         _destinationLocation = location;
///       });
///       break;
///   }
/// }
/// ```
enum BCSearchFieldType {
  /// **Origin field** - Starting point for navigation.
  /// 
  /// This field type is used when users search for their starting location
  /// in navigation mode. Typically labeled as "From" or "Origin".
  origin,

  /// **Destination field** - End point for navigation.
  /// 
  /// This field type is used when users search for their destination location.
  /// Used in both single mode (as the primary field) and navigation mode.
  /// Typically labeled as "To" or "Destination".
  destination,
}

/// Extension methods for BCSearchFieldType enum.
extension BCSearchFieldTypeExtension on BCSearchFieldType {
  /// Returns the default placeholder text for this field type.
  String get placeholder {
    switch (this) {
      case BCSearchFieldType.origin:
        return 'From where?';
      case BCSearchFieldType.destination:
        return 'Where to go?';
    }
  }

  /// Returns the field label for UI display.
  String get label {
    switch (this) {
      case BCSearchFieldType.origin:
        return 'Origin';
      case BCSearchFieldType.destination:
        return 'Destination';
    }
  }

  /// Returns true if this is the origin field.
  bool get isOrigin {
    return this == BCSearchFieldType.origin;
  }

  /// Returns true if this is the destination field.
  bool get isDestination {
    return this == BCSearchFieldType.destination;
  }
}
