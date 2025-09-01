import 'package:flutter/material.dart';
import 'package:becomap/becomap.dart';
import 'models/bc_search_field_type.dart';
import 'models/bc_search_result.dart';

/// **BCSearchResultsList** - Scrollable list widget for displaying search results.
///
/// This widget provides an efficient, scrollable list of search results with
/// proper item styling, selection handling, and accessibility support. It uses
/// ListView.builder for optimal performance with large result sets.
///
/// **Usage Example:**
/// ```dart
/// BCSearchResultsList(
///   results: searchResults,
///   fieldType: BCSearchFieldType.destination,
///   onLocationSelected: (location, fieldType) {
///     print('Selected: ${location.name}');
///     controller.clearSearch(fieldType);
///   },
///   maxHeight: MediaQuery.of(context).size.height * 0.6,
/// )
/// ```
class BCSearchResultsList extends StatelessWidget {
  /// **Search results** - List of locations to display.
  final List<BCLocation> results;

  /// **Field type** - The search field type these results belong to.
  final BCSearchFieldType fieldType;

  /// **Selection callback** - Called when a location is selected.
  final void Function(BCLocation location, BCSearchFieldType fieldType)?
  onLocationSelected;

  /// **Maximum height** - Maximum height of the results list.
  final double? maxHeight;

  /// **Show dividers** - Whether to show dividers between items.
  final bool showDividers;

  /// **Item padding** - Padding around each result item.
  final EdgeInsetsGeometry? itemPadding;

  /// **Enable highlighting** - Whether to highlight search terms in results.
  final bool enableHighlighting;

  /// **Search query** - The query used for highlighting (if enabled).
  final String searchQuery;

  /// **Empty state widget** - Widget to show when results are empty.
  final Widget? emptyState;

  /// **Loading state widget** - Widget to show while loading.
  final Widget? loadingState;

  /// **Is loading** - Whether the list is in loading state.
  final bool isLoading;

  /// **Scroll controller** - Optional scroll controller for the list.
  final ScrollController? scrollController;

  /// Creates a new BCSearchResultsList instance.
  ///
  /// **Parameters:**
  /// - [results] List of search result locations
  /// - [fieldType] The search field type these results belong to
  /// - [onLocationSelected] Callback for location selection
  /// - [maxHeight] Maximum height of the list (default: 60% of screen)
  /// - [showDividers] Whether to show item dividers (default: true)
  /// - [itemPadding] Padding around each item
  /// - [enableHighlighting] Whether to highlight search terms (default: false)
  /// - [searchQuery] Query for highlighting
  /// - [emptyState] Custom empty state widget
  /// - [loadingState] Custom loading state widget
  /// - [isLoading] Whether list is loading (default: false)
  /// - [scrollController] Optional scroll controller
  const BCSearchResultsList({
    super.key,
    required this.results,
    required this.fieldType,
    this.onLocationSelected,
    this.maxHeight,
    this.showDividers = true,
    this.itemPadding,
    this.enableHighlighting = false,
    this.searchQuery = '',
    this.emptyState,
    this.loadingState,
    this.isLoading = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final listMaxHeight = maxHeight ?? screenHeight * 0.6;

    // Show loading state if loading
    if (isLoading) {
      return SizedBox(
        height: listMaxHeight,
        child: loadingState ?? const Center(child: CircularProgressIndicator()),
      );
    }

    // Show empty state if no results
    if (results.isEmpty) {
      return SizedBox(
        height: listMaxHeight,
        child:
            emptyState ??
            const Center(
              child: Text(
                'No results found',
                style: TextStyle(color: Color(0xFF666666), fontSize: 16),
              ),
            ),
      );
    }

    return Container(
      constraints: BoxConstraints(maxHeight: listMaxHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        controller: scrollController,
        shrinkWrap: true,
        itemCount: results.length,
        separatorBuilder: (context, index) {
          return showDividers
              ? const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE0E0E0),
                  indent: 16,
                  endIndent: 16,
                )
              : const SizedBox.shrink();
        },
        itemBuilder: (context, index) {
          final location = results[index];
          return _BCSearchResultItem(
            location: location,
            fieldType: fieldType,
            onTap: onLocationSelected,
            padding: itemPadding,
            enableHighlighting: enableHighlighting,
            searchQuery: searchQuery,
          );
        },
      ),
    );
  }
}

/// **_BCSearchResultItem** - Individual search result item widget.
///
/// This private widget represents a single search result item with proper
/// styling, tap handling, and optional text highlighting.
class _BCSearchResultItem extends StatelessWidget {
  final BCLocation location;
  final BCSearchFieldType fieldType;
  final void Function(BCLocation location, BCSearchFieldType fieldType)? onTap;
  final EdgeInsetsGeometry? padding;
  final bool enableHighlighting;
  final String searchQuery;

  const _BCSearchResultItem({
    required this.location,
    required this.fieldType,
    this.onTap,
    this.padding,
    this.enableHighlighting = false,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final result = BCSearchResult.fromLocation(
      location,
      searchQuery: searchQuery,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap?.call(location, fieldType),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Location icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    result.displayIcon,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Location details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Location name
                    Text(
                      result.displayTitle,
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Location subtitle
                    if (result.displaySubtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        result.displaySubtitle,
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Selection indicator
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF999999),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
