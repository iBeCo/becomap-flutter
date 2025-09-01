import 'package:flutter/material.dart';
import 'package:becomap/becomap.dart';

/// **RouteManager** - Manages route calculation and state for the demo app.
///
/// This class handles the integration between the search system and route display,
/// managing route calculation requests and results from the SDK.
///
/// **Usage Example:**
/// ```dart
/// final routeManager = RouteManager(
///   mapViewKey: _mapViewKey,
///   onRouteCalculated: (segments, start, end) {
///     setState(() {
///       _routeSegments = segments;
///       _showRoute = true;
///     });
///   },
///   onRouteError: (error) {
///     _showErrorDialog('Route Error', error);
///   },
/// );
///
/// // Calculate route when both locations are selected
/// await routeManager.calculateRoute(
///   startLocationName: 'Entrance',
///   endLocationName: 'Conference Room A',
///   startLocationId: 'loc_123',
///   endLocationId: 'loc_456',
/// );
/// ```
class RouteManager {
  /// **Map view key** for accessing SDK functionality
  final GlobalKey<BCMapViewState> mapViewKey;

  /// **Callback** when route calculation succeeds
  final Function(
    List<BCRouteSegment> segments,
    String startName,
    String endName,
  )
  onRouteCalculated;

  /// **Callback** when route calculation fails
  final Function(String error) onRouteError;

  /// **Callback** when route calculation starts
  final VoidCallback? onRouteCalculationStarted;

  /// Current route calculation state
  bool _isCalculatingRoute = false;

  /// Pending route calculation details
  String? _pendingStartName;
  String? _pendingEndName;

  /// Creates a new RouteManager instance.
  RouteManager({
    required this.mapViewKey,
    required this.onRouteCalculated,
    required this.onRouteError,
    this.onRouteCalculationStarted,
  });

  /// **Gets current route calculation state**
  bool get isCalculatingRoute => _isCalculatingRoute;

  /// **Calculate route between two locations**
  ///
  /// This method initiates route calculation using the SDK's getRoute method.
  /// Results will be delivered via the onRouteCalculated callback.
  ///
  /// **Parameters:**
  /// - [startLocation] Starting location object
  /// - [endLocation] Destination location object
  /// - [waypoints] Optional list of waypoint location objects
  ///
  /// **Returns:**
  /// - [Future<void>] Completes when route calculation is initiated
  ///
  /// **Throws:**
  /// - Route calculation errors are handled via onRouteError callback
  Future<void> calculateRoute({
    required BCLocation startLocation,
    required BCLocation endLocation,
    List<BCLocation>? waypoints,
  }) async {
    // Prevent multiple simultaneous route calculations
    if (_isCalculatingRoute) {
      debugPrint('🚫 Route calculation already in progress, ignoring request');
      return;
    }

    try {
      _isCalculatingRoute = true;
      _pendingStartName = startLocation.name;
      _pendingEndName = endLocation.name;

      debugPrint('🧭 Starting route calculation...');
      debugPrint('📍 From: ${startLocation.name} (${startLocation.id})');
      debugPrint('🎯 To: ${endLocation.name} (${endLocation.id})');
      if (waypoints != null && waypoints.isNotEmpty) {
        final waypointNames = waypoints.map((w) => w.name).join(', ');
        debugPrint('🛤️ Waypoints: $waypointNames');
      }

      // Notify that calculation has started
      onRouteCalculationStarted?.call();

      // Create route options with default settings
      final routeOptions = BCRouteOptions.builder()
          .setMaxDistanceThreshold(20) // Hardcoded as requested
          .setGetAccessiblePath(false) // Default to non-accessible path
          .build();

      // Call SDK to calculate route
      await mapViewKey.currentState?.getRoute(
        startLocation: startLocation,
        goalLocation: endLocation,
        waypoints: waypoints,
        routeOptions: routeOptions,
      );

      debugPrint('✅ Route calculation request sent successfully');
    } catch (e) {
      debugPrint('❌ Route calculation failed: $e');
      _isCalculatingRoute = false;
      _pendingStartName = null;
      _pendingEndName = null;

      // Handle errors generically since exception classes are internal to SDK
      String errorMessage = 'Route calculation failed: ${e.toString()}';

      onRouteError(errorMessage);
    }
  }

  /// **Calculate accessible route between two locations**
  ///
  /// Same as calculateRoute but with accessible path option enabled.
  Future<void> calculateAccessibleRoute({
    required BCLocation startLocation,
    required BCLocation endLocation,
    List<BCLocation>? waypoints,
  }) async {
    // Prevent multiple simultaneous route calculations
    if (_isCalculatingRoute) {
      debugPrint('🚫 Route calculation already in progress, ignoring request');
      return;
    }

    try {
      _isCalculatingRoute = true;
      _pendingStartName = startLocation.name;
      _pendingEndName = endLocation.name;

      debugPrint('♿ Starting accessible route calculation...');
      debugPrint('📍 From: ${startLocation.name} (${startLocation.id})');
      debugPrint('🎯 To: ${endLocation.name} (${endLocation.id})');

      // Notify that calculation has started
      onRouteCalculationStarted?.call();

      // Create route options with accessibility enabled
      final routeOptions = BCRouteOptions.builder()
          .setMaxDistanceThreshold(20) // Hardcoded as requested
          .setGetAccessiblePath(true) // Enable accessible path
          .build();

      // Call SDK to calculate route
      await mapViewKey.currentState?.getRoute(
        startLocation: startLocation,
        goalLocation: endLocation,
        waypoints: waypoints,
        routeOptions: routeOptions,
      );

      debugPrint('✅ Accessible route calculation request sent successfully');
    } catch (e) {
      debugPrint('❌ Accessible route calculation failed: $e');
      _isCalculatingRoute = false;
      _pendingStartName = null;
      _pendingEndName = null;

      // Handle errors generically since exception classes are internal to SDK
      String errorMessage =
          'Accessible route calculation failed: ${e.toString()}';

      onRouteError(errorMessage);
    }
  }

  /// **Handle route calculation results from SDK callback**
  ///
  /// This method should be called from the onGetRoute callback to process
  /// the route segments returned by the SDK.
  ///
  /// **Parameters:**
  /// - [segments] Route segments from SDK callback
  void handleRouteResult(List<BCRouteSegment> segments) {
    try {
      debugPrint('📍 Route calculation completed');
      debugPrint('🛤️ Received ${segments.length} route segments');

      // Calculate total distance and steps for logging
      final totalDistance = segments.fold(
        0.0,
        (sum, segment) => sum + segment.distance,
      );
      final totalSteps = segments.fold(
        0,
        (sum, segment) => sum + segment.stepCount,
      );

      debugPrint('📏 Total distance: ${totalDistance.toStringAsFixed(1)}m');
      debugPrint('👣 Total steps: $totalSteps');

      // Log segment details
      for (int i = 0; i < segments.length; i++) {
        final segment = segments[i];
        debugPrint(
          '📍 Segment $i: ${segment.distance.toStringAsFixed(1)}m, ${segment.stepCount} steps',
        );
      }

      // Ensure we have pending route details
      if (_pendingStartName == null || _pendingEndName == null) {
        debugPrint('⚠️ No pending route details found, using default names');
        onRouteCalculated(segments, 'Start', 'End');
      } else {
        onRouteCalculated(segments, _pendingStartName!, _pendingEndName!);
      }
    } catch (e) {
      debugPrint('❌ Error processing route result: $e');
      onRouteError('Failed to process route result: $e');
    } finally {
      // Reset calculation state
      _isCalculatingRoute = false;
      _pendingStartName = null;
      _pendingEndName = null;
    }
  }

  /// **Handle route calculation errors**
  ///
  /// This method should be called when route calculation fails or times out.
  void handleRouteError(String error) {
    debugPrint('❌ Route calculation error: $error');

    _isCalculatingRoute = false;
    _pendingStartName = null;
    _pendingEndName = null;

    onRouteError(error);
  }

  /// **Cancel ongoing route calculation**
  ///
  /// Resets the calculation state without triggering callbacks.
  void cancelRouteCalculation() {
    if (_isCalculatingRoute) {
      debugPrint('🚫 Cancelling route calculation');
      _isCalculatingRoute = false;
      _pendingStartName = null;
      _pendingEndName = null;
    }
  }

  /// **Show step details in console**
  ///
  /// This is a placeholder function for step selection handling.
  /// In the future, this could trigger map focus, highlight the step, etc.
  ///
  /// **Parameters:**
  /// - [step] The selected route step
  static void showStep(BCRouteStep step) {
    debugPrint('👆 Step selected:');
    debugPrint('   Order: ${step.orderIndex}');
    debugPrint('   Action: ${step.action.displayName}');
    debugPrint('   Direction: ${step.direction.displayName}');
    debugPrint('   Distance: ${step.distance.toStringAsFixed(1)}m');
    debugPrint('   Floor: ${step.floorId}');
    debugPrint('   Reference: ${step.reference}');
    if (step.referenceLocationId != null) {
      debugPrint('   Location ID: ${step.referenceLocationId}');
    }

    // TODO: Future functionality could include:
    // - Focus map camera on step location
    // - Highlight step on map
    // - Show step details in UI overlay
    // - Provide audio navigation instructions
    debugPrint('🚧 Step interaction features coming soon...');
  }
}
