import 'package:flutter/material.dart';
import 'package:becomap/becomap.dart';

/// **RouteDisplayModal** - Bottom modal widget for displaying route information.
///
/// This widget provides a two-state modal interface:
/// - Collapsed state: Shows minimal route summary
/// - Expanded state: Shows detailed step-by-step navigation instructions
///
/// **Usage Example:**
/// ```dart
/// RouteDisplayModal(
///   routeSegments: routeSegments,
///   startLocationName: 'Entrance',
///   endLocationName: 'Conference Room A',
///   onStepSelected: (step) => showStep(step),
///   onDismiss: () => setState(() => _showRoute = false),
/// )
/// ```
class RouteDisplayModal extends StatefulWidget {
  /// **Route segments** containing navigation instructions
  final List<BCRouteSegment> routeSegments;

  /// **Start location name** for display in route summary
  final String startLocationName;

  /// **End location name** for display in route summary
  final String endLocationName;

  /// **Callback** when a navigation step is selected
  final Function(BCRouteStep step) onStepSelected;

  /// **Callback** when a route segment should be shown
  final Function(int segmentIndex)? onShowRouteSegment;

  /// **Callback** when modal should be dismissed
  final VoidCallback onDismiss;

  /// **Map view key** for SDK integration (optional)
  final GlobalKey<BCMapViewState>? mapViewKey;

  /// Creates a new RouteDisplayModal widget.
  const RouteDisplayModal({
    super.key,
    required this.routeSegments,
    required this.startLocationName,
    required this.endLocationName,
    required this.onStepSelected,
    this.onShowRouteSegment,
    required this.onDismiss,
    this.mapViewKey,
  });

  @override
  State<RouteDisplayModal> createState() => _RouteDisplayModalState();
}

class _RouteDisplayModalState extends State<RouteDisplayModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  // Drag gesture handling
  double _dragStartY = 0;
  double _currentDragY = 0;

  // Step selection state management
  BCRouteStep? _selectedStep;
  bool _isStepLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Calculate total distance across all route segments
  double get _totalDistance {
    return widget.routeSegments.fold(
      0.0,
      (sum, segment) => sum + segment.distance,
    );
  }

  /// Calculate total number of steps across all route segments
  int get _totalSteps {
    return widget.routeSegments.fold(
      0,
      (sum, segment) => sum + segment.stepCount,
    );
  }

  /// Get all steps from all segments in order
  List<BCRouteStep> get _allSteps {
    final List<BCRouteStep> allSteps = [];
    for (final segment in widget.routeSegments) {
      allSteps.addAll(segment.steps);
    }
    return allSteps;
  }

  /// Handle tap to expand/collapse modal
  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  /// Handle drag start
  void _onDragStart(DragStartDetails details) {
    _dragStartY = details.globalPosition.dy;
    _currentDragY = _dragStartY;
  }

  /// Handle drag update
  void _onDragUpdate(DragUpdateDetails details) {
    _currentDragY = details.globalPosition.dy;
    final dragDistance = _currentDragY - _dragStartY;

    // If dragging up and not expanded, expand
    if (dragDistance < -50 && !_isExpanded) {
      _toggleExpansion();
    }
    // If dragging down and expanded, collapse
    else if (dragDistance > 50 && _isExpanded) {
      _toggleExpansion();
    }
  }

  /// Handle drag end
  void _onDragEnd(DragEndDetails details) {
    // If dragging down with sufficient velocity, dismiss modal
    if (details.velocity.pixelsPerSecond.dy > 500 && !_isExpanded) {
      widget.onDismiss();
    }
  }

  /// Handle step selection with SDK integration and state management
  Future<void> _handleStepSelection(BCRouteStep step) async {
    // Prevent multiple simultaneous step selections
    if (_isStepLoading) return;

    setState(() {
      _isStepLoading = true;
    });

    try {
      // Call the SDK showStep function if mapViewKey is available
      if (widget.mapViewKey?.currentState != null) {
        debugPrint(
          '🎯 Calling SDK showStep for orderIndex: ${step.orderIndex}',
        );
        await widget.mapViewKey!.currentState!.showStep(step);
        debugPrint('✅ SDK showStep completed successfully');
      } else {
        debugPrint('⚠️ MapViewKey not available, falling back to callback');
      }

      // Call the original callback for any additional handling
      widget.onStepSelected(step);

      // Update selected step state
      setState(() {
        _selectedStep = step;
        // Collapse the modal to mini state after step selection
        if (_isExpanded) {
          _isExpanded = false;
          _animationController.reverse();
        }
      });

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Showing step ${step.orderIndex}: ${_getStepDescription(step)}',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }

      debugPrint('🎯 Step selection completed: ${_getStepDescription(step)}');
    } catch (e) {
      debugPrint('❌ Failed to show step ${step.orderIndex}: $e');

      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to show step: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStepLoading = false;
        });
      }
    }
  }

  /// Build collapsed state content
  Widget _buildCollapsedContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), // More bottom padding
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

          // Route summary
          Row(
            children: [
              // Route icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.directions,
                  color: Colors.blue[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Route details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedStep != null
                          ? 'Step ${_selectedStep!.orderIndex}: ${_getStepDescription(_selectedStep!)}'
                          : '${widget.startLocationName} → ${widget.endLocationName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedStep != null
                          ? '${_selectedStep!.distance.toStringAsFixed(1)}m'
                          : '${_totalDistance.toStringAsFixed(1)}m • $_totalSteps steps',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Expand indicator
              Icon(Icons.keyboard_arrow_up, color: Colors.grey[600], size: 24),
            ],
          ),
        ],
      ),
    );
  }

  /// Build expanded state content
  Widget _buildExpandedContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          // Header with drag handle and close button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
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

                // Header row
                Row(
                  children: [
                    // Back button
                    IconButton(
                      onPressed: _toggleExpansion,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),

                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Route Details',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${widget.startLocationName} → ${widget.endLocationName}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Close button
                    IconButton(
                      onPressed: widget.onDismiss,
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Route summary stats
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.straighten,
                        label: 'Distance',
                        value: '${_totalDistance.toStringAsFixed(1)}m',
                      ),
                      _buildStatItem(
                        icon: Icons.list,
                        label: 'Steps',
                        value: '$_totalSteps',
                      ),
                      _buildStatItem(
                        icon: Icons.route,
                        label: 'Segments',
                        value: '${widget.routeSegments.length}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Segment buttons (if multiple segments and callback provided)
          if (widget.routeSegments.length > 1 &&
              widget.onShowRouteSegment != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Route Segments',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < widget.routeSegments.length; i++)
                        ElevatedButton(
                          onPressed: () async {
                            debugPrint('🛤️ Showing route segment $i');
                            try {
                              await widget.onShowRouteSegment?.call(i);
                              debugPrint(
                                '✅ Route segment $i displayed successfully',
                              );
                            } catch (e) {
                              debugPrint(
                                '❌ Failed to show route segment $i: $e',
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[100],
                            foregroundColor: Colors.blue[800],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: const Size(0, 32),
                          ),
                          child: Text(
                            'Segment ${i + 1}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Steps list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _allSteps.length,
              itemBuilder: (context, index) {
                final step = _allSteps[index];
                return _buildStepItem(step, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build a stat item for the summary
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[600], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  /// Build a step item in the list
  Widget _buildStepItem(BCRouteStep step, int index) {
    final isSelected = _selectedStep?.orderIndex == step.orderIndex;
    final isLoading =
        _isStepLoading && _selectedStep?.orderIndex == step.orderIndex;

    return InkWell(
      onTap: () => _handleStepSelection(step),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          color: isSelected ? Colors.blue[50] : null,
        ),
        child: Row(
          children: [
            // Step number with loading/selected state
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue[600]
                    : _getStepColor(step.action),
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: Colors.blue[800]!, width: 2)
                    : null,
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Step details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStepDescription(step),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Distance and selected indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (step.distance > 0)
                  Text(
                    '${step.distance.toStringAsFixed(1)}m',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_circle, color: Colors.blue[600], size: 16),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Get color for step based on action type
  Color _getStepColor(BCStepAction action) {
    switch (action) {
      case BCStepAction.departure:
        return Colors.green;
      case BCStepAction.arrivalDestination:
        return Colors.red;
      case BCStepAction.turn:
        return Colors.blue;
      case BCStepAction.switchFloor:
        return Colors.orange;
      case BCStepAction.none:
        return Colors.grey;
    }
  }

  /// Get description for step
  String _getStepDescription(BCRouteStep step) {
    if (step.action == BCStepAction.departure) {
      return 'Start your journey';
    } else if (step.action == BCStepAction.arrivalDestination) {
      return 'You have arrived at your destination';
    } else if (step.action == BCStepAction.turn) {
      return 'Turn ${step.direction.displayName.toLowerCase()}';
    } else if (step.action == BCStepAction.switchFloor) {
      return 'Switch floor - ${step.direction.displayName.toLowerCase()}';
    } else {
      return step.action.displayName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: 0,
          right: 0,
          bottom:
              MediaQuery.of(context).padding.bottom +
              20, // Add spacing from bottom
          child: GestureDetector(
            onTap: _isExpanded ? null : _toggleExpansion,
            onPanStart: _onDragStart,
            onPanUpdate: _onDragUpdate,
            onPanEnd: _onDragEnd,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _isExpanded
                  ? _buildExpandedContent()
                  : _buildCollapsedContent(),
            ),
          ),
        );
      },
    );
  }
}
