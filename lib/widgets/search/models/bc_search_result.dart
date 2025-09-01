import 'package:becomap/becomap.dart';

/// **BCSearchResult** - Wrapper for search result data with additional metadata.
///
/// This class wraps BCLocation objects with additional search-specific information
/// such as relevance score, match type, and display formatting for search results.
///
/// **Usage Example:**
/// ```dart
/// // Create search result from location
/// final result = BCSearchResult.fromLocation(
///   location,
///   relevanceScore: 0.95,
///   matchType: BCSearchMatchType.name,
/// );
///
/// // Use in search results list
/// ListView.builder(
///   itemCount: searchResults.length,
///   itemBuilder: (context, index) {
///     final result = searchResults[index];
///     return ListTile(
///       title: Text(result.displayTitle),
///       subtitle: Text(result.displaySubtitle),
///       leading: Icon(result.displayIcon),
///     );
///   },
/// )
/// ```
class BCSearchResult {
  /// **Location data** - The underlying BCLocation object.
  final BCLocation location;

  /// **Relevance score** - Search relevance from 0.0 to 1.0.
  /// Higher scores indicate better matches to the search query.
  final double relevanceScore;

  /// **Match type** - Indicates what part of the location matched the search.
  final BCSearchMatchType matchType;

  /// **Highlighted query** - The original search query for highlighting.
  final String searchQuery;

  /// Creates a new BCSearchResult instance.
  ///
  /// **Parameters:**
  /// - [location] The BCLocation object containing location data
  /// - [relevanceScore] Search relevance score (0.0 to 1.0)
  /// - [matchType] Type of match (name, description, category, etc.)
  /// - [searchQuery] Original search query for highlighting
  const BCSearchResult({
    required this.location,
    this.relevanceScore = 1.0,
    this.matchType = BCSearchMatchType.name,
    this.searchQuery = '',
  });

  /// Creates a BCSearchResult from a BCLocation with default values.
  ///
  /// **Parameters:**
  /// - [location] The BCLocation to wrap
  /// - [relevanceScore] Optional relevance score (defaults to 1.0)
  /// - [matchType] Optional match type (defaults to name match)
  /// - [searchQuery] Optional search query for highlighting
  ///
  /// **Returns:**
  /// - BCSearchResult wrapping the provided location
  factory BCSearchResult.fromLocation(
    BCLocation location, {
    double relevanceScore = 1.0,
    BCSearchMatchType matchType = BCSearchMatchType.name,
    String searchQuery = '',
  }) {
    return BCSearchResult(
      location: location,
      relevanceScore: relevanceScore,
      matchType: matchType,
      searchQuery: searchQuery,
    );
  }

  /// Returns the primary display title for this search result.
  ///
  /// Uses location name as the primary title, falling back to ID if name is null.
  String get displayTitle {
    return location.name ?? 'Unknown Location';
  }

  /// Returns the secondary display subtitle for this search result.
  ///
  /// Uses location description, address, or category information as subtitle.
  String get displaySubtitle {
    if (location.description != null && location.description!.isNotEmpty) {
      return location.description!;
    }
    if (location.address != null && location.address!.isNotEmpty) {
      return location.address!;
    }
    if (location.categories != null && location.categories!.isNotEmpty) {
      return location.categories!.first.name ?? 'Category';
    }
    return 'Location details';
  }

  /// Returns the appropriate icon for this search result based on location type.
  String get displayIcon {
    // Default location pin icon for all results
    return '📍';
  }

  /// Returns true if this result has a high relevance score (>= 0.8).
  bool get isHighRelevance => relevanceScore >= 0.8;

  /// Returns true if this result has a medium relevance score (0.5 - 0.8).
  bool get isMediumRelevance => relevanceScore >= 0.5 && relevanceScore < 0.8;

  /// Returns true if this result has a low relevance score (< 0.5).
  bool get isLowRelevance => relevanceScore < 0.5;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BCSearchResult &&
        other.location == location &&
        other.relevanceScore == relevanceScore &&
        other.matchType == matchType &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    return Object.hash(location, relevanceScore, matchType, searchQuery);
  }

  @override
  String toString() {
    return 'BCSearchResult('
        'location: ${location.name}, '
        'relevanceScore: $relevanceScore, '
        'matchType: $matchType, '
        'searchQuery: "$searchQuery"'
        ')';
  }
}

/// **BCSearchMatchType** - Indicates what part of the location matched the search query.
///
/// This enum helps categorize search results and can be used for result ordering,
/// highlighting, or providing additional context to users.
enum BCSearchMatchType {
  /// **Name match** - Search query matched the location name.
  name,

  /// **Description match** - Search query matched the location description.
  description,

  /// **Category match** - Search query matched a location category.
  category,

  /// **Address match** - Search query matched the location address.
  address,

  /// **Amenity match** - Search query matched the location amenity type.
  amenity,

  /// **Tag match** - Search query matched one of the location tags.
  tag,

  /// **Partial match** - Search query partially matched multiple fields.
  partial,
}

/// Extension methods for BCSearchMatchType enum.
extension BCSearchMatchTypeExtension on BCSearchMatchType {
  /// Returns a human-readable description of the match type.
  String get description {
    switch (this) {
      case BCSearchMatchType.name:
        return 'Name match';
      case BCSearchMatchType.description:
        return 'Description match';
      case BCSearchMatchType.category:
        return 'Category match';
      case BCSearchMatchType.address:
        return 'Address match';
      case BCSearchMatchType.amenity:
        return 'Amenity match';
      case BCSearchMatchType.tag:
        return 'Tag match';
      case BCSearchMatchType.partial:
        return 'Partial match';
    }
  }

  /// Returns the priority order for this match type (lower = higher priority).
  int get priority {
    switch (this) {
      case BCSearchMatchType.name:
        return 1;
      case BCSearchMatchType.category:
        return 2;
      case BCSearchMatchType.amenity:
        return 3;
      case BCSearchMatchType.description:
        return 4;
      case BCSearchMatchType.address:
        return 5;
      case BCSearchMatchType.tag:
        return 6;
      case BCSearchMatchType.partial:
        return 7;
    }
  }
}
