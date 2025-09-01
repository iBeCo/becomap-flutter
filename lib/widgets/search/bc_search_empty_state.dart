import 'package:flutter/material.dart';

/// **BCSearchEmptyState** - Empty state widget for search results.
///
/// This widget displays appropriate empty state content when search operations
/// return no results, including helpful messages and optional action buttons
/// to guide users on next steps.
///
/// **Usage Example:**
/// ```dart
/// // Basic empty state
/// BCSearchEmptyState(
///   query: 'coffee shop',
/// )
///
/// // Empty state with retry action
/// BCSearchEmptyState(
///   query: 'restaurant',
///   showRetryButton: true,
///   onRetry: () {
///     controller.performSearch('restaurant', fieldType);
///   },
/// )
///
/// // Custom empty state
/// BCSearchEmptyState(
///   query: 'parking',
///   title: 'No parking found',
///   message: 'Try searching for "garage" or "lot"',
///   icon: Icons.local_parking,
/// )
/// ```
class BCSearchEmptyState extends StatelessWidget {
  /// **Search query** - The query that returned no results.
  final String query;

  /// **Title text** - Main heading for the empty state.
  final String? title;

  /// **Message text** - Descriptive message explaining the empty state.
  final String? message;

  /// **Icon** - Icon to display above the text.
  final IconData? icon;

  /// **Icon color** - Color of the empty state icon.
  final Color? iconColor;

  /// **Show retry button** - Whether to show a retry action button.
  final bool showRetryButton;

  /// **Retry callback** - Called when retry button is tapped.
  final VoidCallback? onRetry;

  /// **Show suggestions** - Whether to show search suggestions.
  final bool showSuggestions;

  /// **Suggestions** - List of suggested search terms.
  final List<String> suggestions;

  /// **Suggestion callback** - Called when a suggestion is tapped.
  final ValueChanged<String>? onSuggestionTapped;

  /// **Compact mode** - Whether to use compact layout.
  final bool compact;

  /// **Background color** - Background color of the empty state container.
  final Color? backgroundColor;

  /// **Padding** - Internal padding around the empty state content.
  final EdgeInsetsGeometry? padding;

  /// Creates a new BCSearchEmptyState instance.
  ///
  /// **Parameters:**
  /// - [query] The search query that returned no results
  /// - [title] Custom title text
  /// - [message] Custom message text
  /// - [icon] Custom icon to display
  /// - [iconColor] Color of the icon
  /// - [showRetryButton] Whether to show retry button (default: false)
  /// - [onRetry] Callback for retry button tap
  /// - [showSuggestions] Whether to show suggestions (default: false)
  /// - [suggestions] List of suggested search terms
  /// - [onSuggestionTapped] Callback for suggestion tap
  /// - [compact] Whether to use compact layout (default: false)
  /// - [backgroundColor] Background color of the container
  /// - [padding] Internal padding around content
  const BCSearchEmptyState({
    super.key,
    required this.query,
    this.title,
    this.message,
    this.icon,
    this.iconColor,
    this.showRetryButton = false,
    this.onRetry,
    this.showSuggestions = false,
    this.suggestions = const [],
    this.onSuggestionTapped,
    this.compact = false,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? Colors.transparent;

    final defaultTitle = query.isEmpty
        ? 'Start typing to search'
        : 'No results found';

    final defaultMessage = query.isEmpty
        ? 'Enter a location name, store, or amenity to find what you\'re looking for'
        : 'We couldn\'t find any locations matching "$query". Try a different search term.';

    if (compact) {
      return Container(
        padding: padding ?? const EdgeInsets.all(16),
        color: bgColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  icon ?? Icons.search_off,
                  color: iconColor ?? const Color(0xFF999999),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title ?? defaultTitle,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),

            // Suggestions in compact mode
            if (showSuggestions && suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions.map((suggestion) {
                  return ActionChip(
                    label: Text(suggestion),
                    onPressed: () => onSuggestionTapped?.call(suggestion),
                    backgroundColor: const Color(0xFFF5F5F5),
                    labelStyle: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 12,
                    ),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(32),
      color: bgColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              icon ?? (query.isEmpty ? Icons.search : Icons.search_off),
              color: iconColor ?? const Color(0xFF999999),
              size: 48,
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              title ?? defaultTitle,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Message
            Text(
              message ?? defaultMessage,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
                fontWeight: FontWeight.normal,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            // Retry button
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],

            // Suggestions
            if (showSuggestions && suggestions.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Try searching for:',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions.map((suggestion) {
                  return ActionChip(
                    label: Text(suggestion),
                    onPressed: () => onSuggestionTapped?.call(suggestion),
                    backgroundColor: const Color(0xFFF5F5F5),
                    labelStyle: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 12,
                    ),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// **BCSearchNoResultsCard** - Card-style empty state for inline display.
///
/// This widget provides a card-style empty state that can be displayed inline
/// with search results or in constrained spaces where the full empty state
/// would be too large.
///
/// **Usage Example:**
/// ```dart
/// // In a list of search results
/// if (results.isEmpty && hasSearched)
///   BCSearchNoResultsCard(
///     query: searchQuery,
///     onClear: () => controller.clearSearch(fieldType),
///   )
/// ```
class BCSearchNoResultsCard extends StatelessWidget {
  /// **Search query** - The query that returned no results.
  final String query;

  /// **Show clear button** - Whether to show a clear search button.
  final bool showClearButton;

  /// **Clear callback** - Called when clear button is tapped.
  final VoidCallback? onClear;

  /// **Card elevation** - Elevation of the card.
  final double elevation;

  /// **Card margin** - External margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Creates a new BCSearchNoResultsCard instance.
  ///
  /// **Parameters:**
  /// - [query] The search query that returned no results
  /// - [showClearButton] Whether to show clear button (default: true)
  /// - [onClear] Callback for clear button tap
  /// - [elevation] Card elevation (default: 2)
  /// - [margin] External margin around card
  const BCSearchNoResultsCard({
    super.key,
    required this.query,
    this.showClearButton = true,
    this.onClear,
    this.elevation = 2,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, color: const Color(0xFF999999), size: 32),

              const SizedBox(height: 12),

              Text(
                'No results for "$query"',
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              const Text(
                'Try a different search term or check your spelling',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),

              if (showClearButton && onClear != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: onClear,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text('Clear Search'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
