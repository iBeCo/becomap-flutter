import '../models/bc_search_field_type.dart';

/// **BCSearchValidator** - Utility class for validating and processing search input.
///
/// This class provides comprehensive validation and processing capabilities for
/// search queries, including length validation, character filtering, query
/// normalization, and search term suggestions.
///
/// **Usage Example:**
/// ```dart
/// final validator = BCSearchValidator();
///
/// // Validate search query
/// final result = validator.validateQuery('coffee shop');
/// if (result.isValid) {
///   performSearch(result.processedQuery);
/// } else {
///   showError(result.errorMessage);
/// }
///
/// // Process and normalize query
/// final normalized = validator.normalizeQuery('  COFFEE   SHOP  ');
/// // Returns: 'coffee shop'
/// ```
class BCSearchValidator {
  /// **Maximum query length** - Maximum allowed characters in search query.
  static const int maxQueryLength = 100;

  /// **Minimum query length** - Minimum required characters for search.
  static const int minQueryLength = 1;

  /// **Forbidden characters** - Characters not allowed in search queries.
  static const List<String> forbiddenCharacters = [
    '<', '>', '"', '\'', '&', ';', '(', ')', '{', '}', '[', ']'
  ];

  /// **Common stop words** - Words typically filtered from search queries.
  static const List<String> stopWords = [
    'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
    'of', 'with', 'by', 'is', 'are', 'was', 'were', 'be', 'been', 'being'
  ];

  /// Creates a new BCSearchValidator instance.
  const BCSearchValidator();

  /// Validates a search query and returns validation result.
  ///
  /// This method performs comprehensive validation including length checks,
  /// character validation, and content analysis.
  ///
  /// **Parameters:**
  /// - [query] The search query to validate
  /// - [fieldType] The field type for context-specific validation
  ///
  /// **Returns:**
  /// - BCSearchValidationResult with validation status and processed query
  ///
  /// **Example:**
  /// ```dart
  /// final result = validator.validateQuery('coffee shop');
  /// if (result.isValid) {
  ///   print('Valid query: ${result.processedQuery}');
  /// } else {
  ///   print('Error: ${result.errorMessage}');
  /// }
  /// ```
  BCSearchValidationResult validateQuery(
    String query, [
    BCSearchFieldType fieldType = BCSearchFieldType.destination,
  ]) {
    // Check for null or empty query
    if (query.isEmpty) {
      return BCSearchValidationResult.invalid(
        'Search query cannot be empty',
        query,
      );
    }

    // Normalize the query
    final normalizedQuery = normalizeQuery(query);

    // Check minimum length after normalization
    if (normalizedQuery.length < minQueryLength) {
      return BCSearchValidationResult.invalid(
        'Search query is too short (minimum $minQueryLength character)',
        normalizedQuery,
      );
    }

    // Check maximum length
    if (normalizedQuery.length > maxQueryLength) {
      return BCSearchValidationResult.invalid(
        'Search query is too long (maximum $maxQueryLength characters)',
        normalizedQuery,
      );
    }

    // Check for forbidden characters
    for (final char in forbiddenCharacters) {
      if (normalizedQuery.contains(char)) {
        return BCSearchValidationResult.invalid(
          'Search query contains invalid character: $char',
          normalizedQuery,
        );
      }
    }

    // Check if query is only whitespace or special characters
    if (normalizedQuery.trim().isEmpty) {
      return BCSearchValidationResult.invalid(
        'Search query must contain valid text',
        normalizedQuery,
      );
    }

    // Additional validation based on field type
    final fieldValidation = _validateForFieldType(normalizedQuery, fieldType);
    if (!fieldValidation.isValid) {
      return fieldValidation;
    }

    return BCSearchValidationResult.valid(normalizedQuery);
  }

  /// Normalizes a search query by trimming, lowercasing, and cleaning.
  ///
  /// This method standardizes search queries for consistent processing
  /// and comparison.
  ///
  /// **Parameters:**
  /// - [query] The raw search query to normalize
  ///
  /// **Returns:**
  /// - Normalized search query string
  ///
  /// **Example:**
  /// ```dart
  /// final normalized = validator.normalizeQuery('  COFFEE   SHOP  ');
  /// // Returns: 'coffee shop'
  /// ```
  String normalizeQuery(String query) {
    return query
        .trim()                           // Remove leading/trailing whitespace
        .toLowerCase()                    // Convert to lowercase
        .replaceAll(RegExp(r'\s+'), ' ')  // Replace multiple spaces with single space
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special characters except hyphens
        .trim();                          // Final trim
  }

  /// Extracts meaningful search terms from a query.
  ///
  /// This method splits the query into individual terms and filters out
  /// stop words and very short terms.
  ///
  /// **Parameters:**
  /// - [query] The search query to extract terms from
  /// - [includeStopWords] Whether to include stop words (default: false)
  ///
  /// **Returns:**
  /// - List of meaningful search terms
  ///
  /// **Example:**
  /// ```dart
  /// final terms = validator.extractSearchTerms('the coffee shop');
  /// // Returns: ['coffee', 'shop']
  /// ```
  List<String> extractSearchTerms(String query, {bool includeStopWords = false}) {
    final normalizedQuery = normalizeQuery(query);
    final terms = normalizedQuery.split(' ');
    
    return terms
        .where((term) => term.length >= 2) // Filter very short terms
        .where((term) => includeStopWords || !stopWords.contains(term)) // Filter stop words
        .toList();
  }

  /// Suggests search corrections for common typos and variations.
  ///
  /// This method provides basic spell correction and search suggestions
  /// based on common location search patterns.
  ///
  /// **Parameters:**
  /// - [query] The search query to suggest corrections for
  ///
  /// **Returns:**
  /// - List of suggested search corrections
  ///
  /// **Example:**
  /// ```dart
  /// final suggestions = validator.suggestCorrections('cofee');
  /// // Returns: ['coffee']
  /// ```
  List<String> suggestCorrections(String query) {
    final normalizedQuery = normalizeQuery(query);
    final suggestions = <String>[];

    // Common typo corrections
    final corrections = {
      'cofee': 'coffee',
      'coffe': 'coffee',
      'resturant': 'restaurant',
      'restraunt': 'restaurant',
      'restaraunt': 'restaurant',
      'bathrom': 'bathroom',
      'bathrrom': 'bathroom',
      'parkin': 'parking',
      'parkng': 'parking',
      'elevater': 'elevator',
      'elevetor': 'elevator',
    };

    // Check for exact matches
    if (corrections.containsKey(normalizedQuery)) {
      suggestions.add(corrections[normalizedQuery]!);
    }

    // Check for partial matches
    for (final entry in corrections.entries) {
      if (normalizedQuery.contains(entry.key) && !suggestions.contains(entry.value)) {
        suggestions.add(normalizedQuery.replaceAll(entry.key, entry.value));
      }
    }

    return suggestions;
  }

  /// Validates query for specific field type requirements.
  BCSearchValidationResult _validateForFieldType(
    String query,
    BCSearchFieldType fieldType,
  ) {
    // Field-specific validation can be added here
    // For now, all field types have the same validation rules
    return BCSearchValidationResult.valid(query);
  }

  /// Checks if a query is likely to be a valid location search.
  ///
  /// **Parameters:**
  /// - [query] The search query to analyze
  ///
  /// **Returns:**
  /// - true if query appears to be a valid location search
  bool isValidLocationQuery(String query) {
    final normalizedQuery = normalizeQuery(query);
    final terms = extractSearchTerms(normalizedQuery);
    
    // Must have at least one meaningful term
    if (terms.isEmpty) return false;
    
    // Check for obviously invalid patterns
    if (normalizedQuery.contains(RegExp(r'\d{10,}'))) return false; // Long numbers
    if (normalizedQuery.contains(RegExp(r'[a-zA-Z]{20,}'))) return false; // Very long words
    
    return true;
  }
}

/// **BCSearchValidationResult** - Result of search query validation.
///
/// This class encapsulates the result of search validation, including
/// validation status, processed query, and error information.
class BCSearchValidationResult {
  /// **Is valid** - Whether the query passed validation.
  final bool isValid;

  /// **Processed query** - The normalized and processed query string.
  final String processedQuery;

  /// **Error message** - Description of validation error (if any).
  final String? errorMessage;

  /// **Suggestions** - Suggested corrections or alternatives.
  final List<String> suggestions;

  /// Creates a new BCSearchValidationResult instance.
  const BCSearchValidationResult({
    required this.isValid,
    required this.processedQuery,
    this.errorMessage,
    this.suggestions = const [],
  });

  /// Creates a valid validation result.
  ///
  /// **Parameters:**
  /// - [processedQuery] The validated and processed query
  /// - [suggestions] Optional suggestions for query improvement
  ///
  /// **Returns:**
  /// - BCSearchValidationResult indicating successful validation
  factory BCSearchValidationResult.valid(
    String processedQuery, [
    List<String> suggestions = const [],
  ]) {
    return BCSearchValidationResult(
      isValid: true,
      processedQuery: processedQuery,
      suggestions: suggestions,
    );
  }

  /// Creates an invalid validation result.
  ///
  /// **Parameters:**
  /// - [errorMessage] Description of the validation error
  /// - [processedQuery] The processed query (may be partially valid)
  /// - [suggestions] Suggested corrections or alternatives
  ///
  /// **Returns:**
  /// - BCSearchValidationResult indicating validation failure
  factory BCSearchValidationResult.invalid(
    String errorMessage,
    String processedQuery, [
    List<String> suggestions = const [],
  ]) {
    return BCSearchValidationResult(
      isValid: false,
      processedQuery: processedQuery,
      errorMessage: errorMessage,
      suggestions: suggestions,
    );
  }

  @override
  String toString() {
    return 'BCSearchValidationResult('
        'isValid: $isValid, '
        'processedQuery: "$processedQuery", '
        'errorMessage: $errorMessage, '
        'suggestions: $suggestions'
        ')';
  }
}
