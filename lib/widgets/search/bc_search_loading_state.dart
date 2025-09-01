import 'package:flutter/material.dart';

/// **BCSearchLoadingState** - Loading indicator widget for search operations.
///
/// This widget displays a loading indicator with optional message text while
/// search operations are in progress. It provides consistent loading UI across
/// all search-related components.
///
/// **Usage Example:**
/// ```dart
/// // Basic loading state
/// BCSearchLoadingState()
///
/// // Loading state with custom message
/// BCSearchLoadingState(
///   message: 'Searching for locations...',
///   showMessage: true,
/// )
///
/// // Compact loading state for inline use
/// BCSearchLoadingState(
///   compact: true,
///   size: 20,
/// )
/// ```
class BCSearchLoadingState extends StatelessWidget {
  /// **Loading message** - Text to display below the loading indicator.
  final String message;

  /// **Show message** - Whether to display the loading message.
  final bool showMessage;

  /// **Compact mode** - Whether to use compact layout for inline display.
  final bool compact;

  /// **Indicator size** - Size of the loading indicator.
  final double size;

  /// **Indicator color** - Color of the loading indicator.
  final Color? color;

  /// **Background color** - Background color of the loading container.
  final Color? backgroundColor;

  /// **Padding** - Internal padding around the loading content.
  final EdgeInsetsGeometry? padding;

  /// Creates a new BCSearchLoadingState instance.
  ///
  /// **Parameters:**
  /// - [message] Loading message text (default: 'Searching...')
  /// - [showMessage] Whether to show the message (default: true)
  /// - [compact] Whether to use compact layout (default: false)
  /// - [size] Size of the loading indicator (default: 24)
  /// - [color] Color of the loading indicator
  /// - [backgroundColor] Background color of the container
  /// - [padding] Internal padding around content
  const BCSearchLoadingState({
    super.key,
    this.message = 'Searching...',
    this.showMessage = true,
    this.compact = false,
    this.size = 24,
    this.color,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.primaryColor;
    final bgColor = backgroundColor ?? Colors.transparent;

    if (compact) {
      return Container(
        padding: padding ?? const EdgeInsets.all(8),
        color: bgColor,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
              ),
            ),
            if (showMessage) ...[
              const SizedBox(width: 8),
              Text(
                message,
                style: TextStyle(
                  color: const Color(0xFF666666),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
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
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
              ),
            ),
            if (showMessage) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  color: const Color(0xFF666666),
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// **BCSearchLoadingOverlay** - Full-screen loading overlay for search operations.
///
/// This widget provides a semi-transparent overlay with loading indicator that
/// can be displayed over the entire search interface during long-running operations.
///
/// **Usage Example:**
/// ```dart
/// Stack(
///   children: [
///     // Main search content
///     SearchContent(),
///     
///     // Show overlay when loading
///     if (isLoading)
///       BCSearchLoadingOverlay(
///         message: 'Searching locations...',
///       ),
///   ],
/// )
/// ```
class BCSearchLoadingOverlay extends StatelessWidget {
  /// **Loading message** - Text to display with the loading indicator.
  final String message;

  /// **Show message** - Whether to display the loading message.
  final bool showMessage;

  /// **Overlay color** - Background color of the overlay.
  final Color overlayColor;

  /// **Indicator color** - Color of the loading indicator.
  final Color? indicatorColor;

  /// **Dismissible** - Whether tapping the overlay dismisses it.
  final bool dismissible;

  /// **On dismiss callback** - Called when overlay is dismissed.
  final VoidCallback? onDismiss;

  /// Creates a new BCSearchLoadingOverlay instance.
  ///
  /// **Parameters:**
  /// - [message] Loading message text (default: 'Searching...')
  /// - [showMessage] Whether to show the message (default: true)
  /// - [overlayColor] Background overlay color
  /// - [indicatorColor] Color of the loading indicator
  /// - [dismissible] Whether overlay can be dismissed (default: false)
  /// - [onDismiss] Callback for overlay dismissal
  const BCSearchLoadingOverlay({
    super.key,
    this.message = 'Searching...',
    this.showMessage = true,
    this.overlayColor = const Color(0x80000000),
    this.indicatorColor,
    this.dismissible = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = indicatorColor ?? theme.primaryColor;

    return GestureDetector(
      onTap: dismissible ? onDismiss : null,
      child: Container(
        color: overlayColor,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
                  ),
                ),
                if (showMessage) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (dismissible) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Tap to cancel',
                    style: TextStyle(
                      color: const Color(0xFF999999),
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// **BCSearchProgressIndicator** - Inline progress indicator for search fields.
///
/// This widget provides a small progress indicator that can be displayed inline
/// with search fields to show search progress without taking up much space.
///
/// **Usage Example:**
/// ```dart
/// Row(
///   children: [
///     Expanded(child: BCSearchField(...)),
///     if (isSearching)
///       BCSearchProgressIndicator(),
///   ],
/// )
/// ```
class BCSearchProgressIndicator extends StatelessWidget {
  /// **Size** - Size of the progress indicator.
  final double size;

  /// **Color** - Color of the progress indicator.
  final Color? color;

  /// **Stroke width** - Width of the progress indicator stroke.
  final double strokeWidth;

  /// Creates a new BCSearchProgressIndicator instance.
  ///
  /// **Parameters:**
  /// - [size] Size of the indicator (default: 16)
  /// - [color] Color of the indicator
  /// - [strokeWidth] Width of the indicator stroke (default: 2)
  const BCSearchProgressIndicator({
    super.key,
    this.size = 16,
    this.color,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
        ),
      ),
    );
  }
}
