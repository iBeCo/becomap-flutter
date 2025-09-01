import 'package:flutter/material.dart';
import 'package:becomap/becomap.dart';

/// A compact bottom modal widget that displays essential information about a selected location.
///
/// This modal slides up from the bottom edge of the screen with a clean, compact design.
/// It appears as a bottom card with rounded corners and proper spacing, showing essential
/// location details in a structured layout with a full-width navigate button.
///
/// **Layout Structure:**
/// - Positioned at bottom of screen with proper margins
/// - Drag handle at the top for visual feedback
/// - Location info row: icon, name/categories, close button
/// - Full-width Navigate button below
/// - Proper spacing to prevent overlapping
///
/// **Features:**
/// - Bottom card presentation (slides up from bottom edge)
/// - Clean two-row layout (info row + button row)
/// - Location icon/image on the left
/// - Location name and categories in the center
/// - Close button on the right of info row
/// - Full-width Navigate button below
/// - Smooth slide-up animation from bottom
/// - Drag-to-dismiss functionality
/// - Proper safe area handling
///
/// **Usage Example:**
/// ```dart
/// LocationDetailsModal(
///   location: selectedLocation,
///   onClose: () => setState(() => _showLocationDetails = false),
///   onNavigate: () => navigateToLocation(selectedLocation),
/// )
/// ```
class LocationDetailsModal extends StatefulWidget {
  /// **Location** to display details for
  final BCLocation location;

  /// **Callback** when modal should be closed
  final VoidCallback onClose;

  /// **Callback** when user wants to navigate to this location
  final VoidCallback? onNavigate;

  /// Creates a new LocationDetailsModal widget.
  const LocationDetailsModal({
    super.key,
    required this.location,
    required this.onClose,
    this.onNavigate,
  });

  @override
  State<LocationDetailsModal> createState() => _LocationDetailsModalState();
}

class _LocationDetailsModalState extends State<LocationDetailsModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Drag gesture handling
  double _dragStartY = 0;
  double _currentDragY = 0;

  @override
  void initState() {
    super.initState();

    // Initialize slide animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation =
        Tween<double>(
          begin: 1.0, // Start off-screen (bottom)
          end: 0.0, // End at final position
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start the slide-up animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Handle drag start
  void _onDragStart(DragStartDetails details) {
    _dragStartY = details.globalPosition.dy;
    _currentDragY = _dragStartY;
  }

  /// Handle drag update
  void _onDragUpdate(DragUpdateDetails details) {
    _currentDragY = details.globalPosition.dy;
  }

  /// Handle drag end
  void _onDragEnd(DragEndDetails details) {
    final dragDistance = _currentDragY - _dragStartY;

    // If dragging down with sufficient distance or velocity, dismiss modal
    if (dragDistance > 100 || details.velocity.pixelsPerSecond.dy > 500) {
      _dismissModal();
    }
  }

  /// Dismiss the modal with slide-down animation
  void _dismissModal() async {
    await _animationController.reverse();
    widget.onClose();
  }

  /// Build the main content of the modal (compact collapsed state)
  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Location info row (without navigate button)
          _buildLocationInfo(),

          const SizedBox(height: 16),

          // Full width navigate button below
          _buildNavigateButton(),
        ],
      ),
    );
  }

  /// Build location info row (icon, name, categories, close button)
  Widget _buildLocationInfo() {
    return Row(
      children: [
        // Location image/icon (left side)
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.place, color: Colors.blue[600], size: 24),
        ),
        const SizedBox(width: 12),

        // Location details (center)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location name
              Text(
                widget.location.name ?? 'Unknown Location',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Categories as subtitle
              if (widget.location.categories?.isNotEmpty == true)
                Text(
                  widget.location.categories!
                      .map((category) => category.name ?? 'Category')
                      .join(' • '),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),

        // Close button (right side)
        IconButton(
          onPressed: _dismissModal,
          icon: const Icon(Icons.close),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          iconSize: 20,
        ),
      ],
    );
  }

  /// Build full width navigate button
  Widget _buildNavigateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onNavigate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Navigate',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Transform.translate(
            offset: Offset(
              0,
              _slideAnimation.value * 200,
            ), // Slide up from bottom
            child: GestureDetector(
              onPanStart: _onDragStart,
              onPanUpdate: _onDragUpdate,
              onPanEnd: _onDragEnd,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: _buildContent(),
              ),
            ),
          ),
        );
      },
    );
  }
}
