import 'package:flutter/material.dart';
import 'package:becomap/becomap.dart';

/// A floor switcher widget that displays available floors and allows selection.
///
/// This widget shows a compact button with the current floor that expands
/// to display all available floors when tapped. It follows the design pattern
/// shown in the UI mockups with a green button and expandable list.
class FloorSwitcher extends StatefulWidget {
  /// The site containing building and floor data
  final BCSite? site;

  /// Callback when a floor is selected
  final Function(BCMapFloor floor)? onFloorSelected;

  /// The currently selected floor
  final BCMapFloor? selectedFloor;

  /// Whether the floor switcher is expanded
  final bool isExpanded;

  /// Callback when expansion state changes
  final Function(bool isExpanded)? onExpansionChanged;

  const FloorSwitcher({
    super.key,
    this.site,
    this.onFloorSelected,
    this.selectedFloor,
    this.isExpanded = false,
    this.onExpansionChanged,
  });

  @override
  State<FloorSwitcher> createState() => _FloorSwitcherState();
}

class _FloorSwitcherState extends State<FloorSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(FloorSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Gets the first building from the site
  BCBuilding? get _firstBuilding {
    if (widget.site?.buildings?.isNotEmpty == true) {
      return widget.site!.buildings!.first;
    }
    return null;
  }

  /// Gets the floors sorted by elevation (highest to lowest for display)
  List<BCMapFloor> get _sortedFloors {
    final building = _firstBuilding;
    if (building?.floors?.isNotEmpty == true) {
      final floors = List<BCMapFloor>.from(building!.floors!);
      // Sort by elevation descending (highest floors first)
      floors.sort((a, b) {
        final elevationA = a.elevation ?? 0.0;
        final elevationB = b.elevation ?? 0.0;
        return elevationB.compareTo(elevationA);
      });
      return floors;
    }
    return [];
  }

  /// Gets the display text for the current floor
  String get _currentFloorDisplay {
    if (widget.selectedFloor != null) {
      return _getShortDisplayName(widget.selectedFloor!);
    }

    // Default to ground floor or first available floor
    final floors = _sortedFloors;
    if (floors.isNotEmpty) {
      final groundFloor = floors.firstWhere(
        (floor) => floor.isGroundFloor,
        orElse: () => floors.first,
      );
      return _getShortDisplayName(groundFloor);
    }

    return 'G';
  }

  /// Gets a short display name suitable for the compact button
  String _getShortDisplayName(BCMapFloor floor) {
    // Use shortName if available
    if (floor.shortName != null && floor.shortName!.isNotEmpty) {
      return floor.shortName!;
    }

    // Generate short name based on elevation
    if (floor.elevation != null) {
      if (floor.elevation == 0.0) {
        return 'G';
      } else if (floor.elevation! > 0) {
        return '${floor.elevation!.toInt()}';
      } else {
        return '-${(-floor.elevation!).toInt()}';
      }
    }

    // Fallback to first character of name
    if (floor.name != null && floor.name!.isNotEmpty) {
      return floor.name!.substring(0, 1).toUpperCase();
    }

    return '?';
  }

  void _toggleExpansion() {
    widget.onExpansionChanged?.call(!widget.isExpanded);
  }

  void _selectFloor(BCMapFloor floor) {
    widget.onFloorSelected?.call(floor);
    widget.onExpansionChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    final floors = _sortedFloors;

    // Don't show if no floors available
    if (floors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 100,
      left: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Expanded floor list
          if (widget.isExpanded)
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: floors.map((floor) {
                      final isSelected = widget.selectedFloor?.id == floor.id;
                      return _buildFloorItem(floor, isSelected);
                    }).toList(),
                  ),
                ),
              ),
            ),

          // Main floor button
          _buildMainButton(),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50), // Green color from design
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _currentFloorDisplay,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloorItem(BCMapFloor floor, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectFloor(floor),
      child: Container(
        width: 56,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            _getShortDisplayName(floor),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
