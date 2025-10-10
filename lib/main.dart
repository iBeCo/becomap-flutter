import 'package:flutter/material.dart';
import 'package:becomap/becomap.dart';
import 'config/app_config.dart';
import 'screens/splash_screen.dart';
import 'widgets/floor_switcher.dart';
import 'widgets/location/location_details_modal.dart';
import 'widgets/search/bc_location_search_widget.dart';
import 'widgets/search/models/bc_search_mode.dart';
import 'widgets/search/models/bc_search_field_type.dart';
import 'widgets/route/route_display_modal.dart';
import 'widgets/route/route_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize configuration from .env file
  await AppConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AppWrapper(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<BCMapViewState> _mapViewKey = GlobalKey<BCMapViewState>();
  bool _isMapLoading = true;
  bool _hasInitError = false;
  BCSite? _currentSite;
  BCMapFloor? _selectedFloor;
  bool _isFloorSwitcherExpanded = false;
  BCLocation? _selectedLocation;
  bool _showLocationDetails = false;

  // Search widget state
  bool _showSearchWidget = false;
  BCSearchMode _searchMode = BCSearchMode.single;
  Key _searchWidgetKey = const ValueKey('search_default');
  String? _navigationDestination;

  // Navigation state tracking
  String? _navigationOrigin;
  String? _navigationDestinationFilled;
  BCLocation? _navigationOriginLocation;
  BCLocation? _navigationDestinationLocation;

  // Route display state
  bool _showRoute = false;
  List<BCRouteSegment> _routeSegments = [];
  String _routeStartName = '';
  String _routeEndName = '';
  bool _isCalculatingRoute = false;

  // Route manager
  late RouteManager _routeManager;

  @override
  void initState() {
    super.initState();

    // Initialize route manager
    _routeManager = RouteManager(
      mapViewKey: _mapViewKey,
      onRouteCalculated: (segments, startName, endName) {
        debugPrint('🎯 Route calculation completed successfully');
        debugPrint('📍 Route: $startName → $endName');
        debugPrint('🛤️ Segments: ${segments.length}');

        setState(() {
          _routeSegments = segments;
          _routeStartName = startName;
          _routeEndName = endName;
          _showRoute = true;
          _isCalculatingRoute = false;
          // Hide search widget when route is displayed
          _showSearchWidget = false;
        });

        // Automatically show the route on the map after successful calculation
        _showRouteOnMap();
      },
      onRouteError: (error) {
        setState(() {
          _isCalculatingRoute = false;
        });
        _showErrorDialog('Route Calculation Failed', error);
      },
      onRouteCalculationStarted: () {
        setState(() {
          _isCalculatingRoute = true;
        });
      },
    );
  }

  /// Show error dialog for initialization failures
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  /// Performs location search using the WebView-based search functionality
  Future<List<BCLocation>> _performLocationSearch(
    String query,
    BCSearchFieldType fieldType,
  ) async {
    debugPrint('🔍 Performing search: "$query" for ${fieldType.label}');
    debugPrint('🔍 Current search mode: $_searchMode');
    debugPrint('🔍 Search widget visible: $_showSearchWidget');

    try {
      // Use the new searchLocation method that returns actual results
      final results =
          await _mapViewKey.currentState?.searchLocation(query) ?? [];

      debugPrint('🔍 Search results: ${results.length} locations found');

      // Log first few results for debugging
      if (results.isNotEmpty) {
        for (int i = 0; i < (results.length > 3 ? 3 : results.length); i++) {
          debugPrint('🔍 Result $i: ${results[i].name} (${results[i].id})');
        }
      }

      // Limit results to prevent UI overflow
      return results.take(10).toList();
    } catch (e) {
      // Handle search errors gracefully
      debugPrint('🔍 Location search failed: $e');
      return [];
    }
  }

  /// Applies the viewport configuration from a floor to the map
  Future<void> _applyFloorViewport(BCMapFloor floor) async {
    try {
      // Validate that map is ready before applying viewport
      if (_mapViewKey.currentState == null) {
        debugPrint(
          '⚠️ Map not ready, skipping viewport for ${floor.displayName}',
        );
        return;
      }

      // Check if the floor has viewport configuration
      if (floor.viewPort == null) {
        debugPrint(
          '🗺️ Floor ${floor.displayName} has no viewport configuration',
        );
        return;
      }

      debugPrint('🗺️ Applying viewport for floor: ${floor.displayName}');

      // Convert the viewport data to BCViewOptions
      final viewportData = floor.viewPort!;
      final viewOptions = BCViewOptions(
        center: viewportData['center'] != null
            ? List<double>.from(viewportData['center'])
            : null,
        zoom: viewportData['zoom']?.toDouble(),
        bearing: viewportData['bearing']?.toDouble(),
        pitch: viewportData['pitch']?.toDouble(),
      );

      // Validate viewport values before applying
      if (viewOptions.center == null || viewOptions.center!.length != 2) {
        debugPrint('❌ Invalid viewport center for floor: ${floor.displayName}');
        return;
      }

      // Apply the viewport to the map
      await _mapViewKey.currentState?.setViewport(viewOptions);

      debugPrint('✅ Applied viewport for floor: ${floor.displayName}');
      debugPrint('📍 Center: ${viewOptions.center}');
      debugPrint('🔍 Zoom: ${viewOptions.zoom}');
      debugPrint('🧭 Bearing: ${viewOptions.bearing}');
      debugPrint('📐 Pitch: ${viewOptions.pitch}');
    } catch (e) {
      debugPrint(
        '❌ Failed to apply floor viewport for ${floor.displayName}: $e',
      );

      // Don't show error dialog for viewport issues as they're not critical
      // The map will continue to work with the current viewport
    }
  }

  /// Handles location selection from search results
  void _onLocationSelected(BCLocation location, BCSearchFieldType fieldType) {
    debugPrint('🔍 Location selected: ${location.name} (${fieldType.label})');
    debugPrint('🔍 Location ID: ${location.id}');
    debugPrint('🔍 Search mode: $_searchMode');

    // Check if we're in navigation mode
    if (_searchMode == BCSearchMode.navigation) {
      // In navigation mode: just fill the field and trigger navigation function
      debugPrint('🧭 Handling navigation location selection');
      _handleNavigationLocationSelection(location, fieldType);
    } else {
      // In single mode: select location on map and show location details
      debugPrint('📍 Handling single mode location selection');
      _selectLocationAndShowDetails(location);
    }
  }

  /// Selects a location on the map via SDK - location details will be shown via onLocationsSelected callback
  void _selectLocationAndShowDetails(BCLocation location) async {
    try {
      // Hide search widget immediately when user makes selection
      setState(() {
        _showSearchWidget = false;
      });

      // Call SDK selectLocation method to trigger map selection
      // Location details will be shown when onLocationsSelected callback is triggered
      await _mapViewKey.currentState?.selectLocation(location);

      debugPrint('✅ Location selection initiated: ${location.name}');
      debugPrint(
        '📋 Location details will be shown via onLocationsSelected callback',
      );
    } catch (e) {
      debugPrint('❌ Failed to select location: $e');

      // Fallback: show location details directly if SDK call fails
      setState(() {
        _selectedLocation = location;
        _showLocationDetails = true;
      });
    }
  }

  /// Handle location selection in navigation mode
  void _handleNavigationLocationSelection(
    BCLocation location,
    BCSearchFieldType fieldType,
  ) {
    debugPrint(
      '🧭 Navigation location selected: ${location.name} for ${fieldType.label}',
    );

    // Update the appropriate field value and store location object
    setState(() {
      if (fieldType == BCSearchFieldType.origin) {
        _navigationOrigin = location.name;
        _navigationOriginLocation = location;
        debugPrint('🔄 Updated origin: $_navigationOrigin (${location.id})');
      } else {
        _navigationDestinationFilled = location.name;
        _navigationDestinationLocation = location;
        debugPrint(
          '🔄 Updated destination: $_navigationDestinationFilled (${location.id})',
        );
      }
    });

    debugPrint(
      '🔍 Current state - Origin: $_navigationOrigin, Destination: $_navigationDestinationFilled',
    );
    debugPrint(
      '🔍 Current locations - Origin: ${_navigationOriginLocation?.id}, Destination: ${_navigationDestinationLocation?.id}',
    );

    // Check if both fields are now filled and trigger route calculation
    if (_navigationOrigin != null &&
        _navigationDestinationFilled != null &&
        _navigationOriginLocation != null &&
        _navigationDestinationLocation != null) {
      debugPrint('✅ Both locations selected, triggering route calculation...');
      _triggerRouteCalculation();
    } else {
      debugPrint('⏳ Waiting for both locations to be selected...');
      debugPrint('   Origin filled: ${_navigationOrigin != null}');
      debugPrint(
        '   Destination filled: ${_navigationDestinationFilled != null}',
      );
      debugPrint(
        '   Origin location available: ${_navigationOriginLocation != null}',
      );
      debugPrint(
        '   Destination location available: ${_navigationDestinationLocation != null}',
      );
    }
  }

  /// Trigger route calculation when both origin and destination are available
  void _triggerRouteCalculation() async {
    debugPrint('🚀 Route calculation triggered!');
    debugPrint(
      '📍 Origin: $_navigationOrigin (${_navigationOriginLocation?.id})',
    );
    debugPrint(
      '🎯 Destination: $_navigationDestinationFilled (${_navigationDestinationLocation?.id})',
    );

    // Ensure we have all required data
    if (_navigationOrigin == null ||
        _navigationDestinationFilled == null ||
        _navigationOriginLocation == null ||
        _navigationDestinationLocation == null) {
      debugPrint('❌ Missing required route data');
      return;
    }

    try {
      // Use route manager to calculate route
      await _routeManager.calculateRoute(
        startLocation: _navigationOriginLocation!,
        endLocation: _navigationDestinationLocation!,
      );
    } catch (e) {
      debugPrint('❌ Route calculation failed: $e');
      _showErrorDialog('Route Error', 'Failed to calculate route: $e');
    }
  }

  /// Resets the search widget to its default state
  void _resetSearchWidgetToDefault() {
    debugPrint('🔄 Resetting search widget to default state');

    // Reset search widget visibility and mode
    _showSearchWidget = false;
    _searchMode = BCSearchMode.single;

    // Clear all navigation-related state
    _navigationOrigin = null;
    _navigationDestination = null;
    _navigationDestinationFilled = null;
    _navigationOriginLocation = null;
    _navigationDestinationLocation = null;

    // Clear location details state to prevent duplicate detection issues
    _selectedLocation = null;
    _showLocationDetails = false;

    // Clear SDK-side selected location state to allow re-selection of same location
    _clearSDKSelectedLocationState();

    // Clear route visualization from map when resetting
    _clearRouteFromMap();

    debugPrint(
      '✅ Search widget reset to default: single mode, no populated data, location details cleared, SDK state cleared',
    );
  }

  /// Clears the SDK-side selected location state to allow re-selection
  void _clearSDKSelectedLocationState() {
    // This will clear the _currentlySelectedLocationId in the MapController
    // allowing the same location to be selected again
    try {
      _mapViewKey.currentState?.clearSelectedLocationState();
      debugPrint('🧹 SDK selected location state cleared successfully');
    } catch (e) {
      debugPrint('⚠️ Failed to clear SDK state: $e');
    }
  }

  /// Automatically shows the calculated route on the map
  void _showRouteOnMap() async {
    try {
      debugPrint('🛤️ Automatically showing route on map after calculation');

      // Show the first segment (index 0) to display the route
      // This works around the JavaScript validation issue with undefined segmentIndex
      if (_routeSegments.isNotEmpty) {
        await _mapViewKey.currentState?.showRoute(0);
        debugPrint(
          '✅ Route automatically displayed on map (showing first segment)',
        );
      } else {
        debugPrint('⚠️ No route segments available to display');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to automatically show route on map: $e');
      // Don't throw error - this is a non-critical enhancement
      // The route modal will still be shown even if map display fails
    }
  }

  /// Clears route visualization from the map
  void _clearRouteFromMap() async {
    try {
      debugPrint('🧹 Clearing route visualization from map');
      await _mapViewKey.currentState?.clearRoute();
      debugPrint('✅ Route cleared from map successfully');
    } catch (e) {
      debugPrint('⚠️ Failed to clear route from map: $e');
      // Don't throw error - this is a non-critical cleanup operation
    }
  }

  /// Forces a complete rebuild of the search widget to clear any stale state
  void _forceSearchWidgetRebuild() {
    // Increment a key to force widget rebuild
    setState(() {
      _searchWidgetKey = ValueKey(
        'search_${DateTime.now().millisecondsSinceEpoch}',
      );
    });
  }

  /// Gets the dynamic app bar title based on current state
  String _getAppBarTitle() {
    if (_isMapLoading) {
      return 'Loading Map...';
    }

    if (_hasInitError) {
      return 'Map Error';
    }

    if (_showSearchWidget) {
      if (_searchMode == BCSearchMode.navigation) {
        return 'Navigation';
      } else {
        return 'Search Locations';
      }
    }

    if (_showRoute) {
      return 'Route Details';
    }

    if (_showLocationDetails && _selectedLocation != null) {
      return _selectedLocation!.name ?? 'Location Details';
    }

    return widget.title; // Default title: 'Becomap Demo'
  }

  /// Clear all selections on the map
  Future<void> _clearMapSelections() async {
    try {
      await _mapViewKey.currentState?.clearSelection();
      debugPrint('✅ Map selections cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear map selections: $e');
    }
  }

  /// Handle navigation request from LocationDetailsModal
  void _onNavigateToLocation() {
    if (_selectedLocation != null) {
      final selectedLocation =
          _selectedLocation!; // Store reference before clearing

      setState(() {
        // Set navigation destination for both UI and tracking
        _navigationDestination = selectedLocation.name;
        _navigationDestinationFilled = selectedLocation.name;
        _navigationDestinationLocation =
            selectedLocation; // Store the location object!

        // Switch to navigation mode
        _searchMode = BCSearchMode.navigation;

        // Show search widget
        _showSearchWidget = true;

        // Hide location details
        _showLocationDetails = false;
        _selectedLocation = null;
      });

      // Clear map selections when switching to navigation mode
      _clearMapSelections();

      debugPrint(
        '🧭 Navigation mode activated with destination: $_navigationDestinationFilled (${selectedLocation.id})',
      );
      debugPrint(
        '🔍 Destination location stored: ${_navigationDestinationLocation?.id}',
      );
    }
  }

  /// Handle search widget mode changes
  void _onSearchModeChanged(BCSearchMode mode) {
    setState(() {
      _searchMode = mode;
      // Clear navigation state when switching modes
      if (mode == BCSearchMode.single) {
        _navigationDestination = null;
        _navigationOrigin = null;
        _navigationDestinationFilled = null;
        _navigationOriginLocation = null;
        _navigationDestinationLocation = null;
        _showRoute = false;
        _routeSegments.clear();
      }
    });
  }

  /// Toggles search widget visibility
  void _toggleSearchWidget() {
    setState(() {
      if (_showSearchWidget) {
        // Closing search widget - reset to default state
        _resetSearchWidgetToDefault();
        _forceSearchWidgetRebuild();
      } else {
        // Opening search widget
        _showSearchWidget = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_getAppBarTitle()),
        actions: [
          // Search icon in app bar - hide when route is displayed
          if (!_isMapLoading && !_hasInitError && !_showRoute)
            IconButton(
              onPressed: _toggleSearchWidget,
              icon: Icon(
                _showSearchWidget ? Icons.close : Icons.search,
                color: Colors.white,
              ),
              tooltip: _showSearchWidget ? 'Close search' : 'Search locations',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Show BCMapView only if there's no init error
          if (!_hasInitError)
            BCMapView(
              key: _mapViewKey,
              onMapReady: () async {
                // Add a small delay to ensure WebView is fully ready
                await Future.delayed(const Duration(milliseconds: 500));

                // Ensure loading state is active during initialization
                setState(() {
                  _isMapLoading = true;
                });

                // Initialize the map with real configuration
                try {
                  final initOptions = BCMapInitOptions.builder()
                      .setClientId(AppConfig.clientId)
                      .setClientSecret(AppConfig.clientSecret)
                      .setSiteIdentifier(AppConfig.siteIdentifier)
                      .build();

                  final siteOptions = BCMapSiteOptions.builder()
                      .setBackgroundColor("#E5E5E5")
                      .build();

                  // Initialize the map
                  await _mapViewKey.currentState?.initialiseMap(
                    initOptions,
                    siteOptions,
                  );
                } catch (error) {
                  debugPrint('Initialization failed: $error');

                  // Hide loading indicator and map on initialization failure
                  setState(() {
                    _isMapLoading = false;
                    _hasInitError = true;
                  });

                  // Show error dialog for initialization failures
                  _showErrorDialog(
                    'Map Initialization Failed',
                    'Failed to initialize map: $error',
                  );
                }
              },
              onError: (errorType, errorMessage) {
                debugPrint('🚨 === MAP ERROR ===');
                debugPrint('🔴 Error Type: $errorType');
                debugPrint('💬 Error Message: $errorMessage');
                debugPrint('==================');

                // Handle initialization errors by hiding the map completely
                if (errorType == 'InitError') {
                  setState(() {
                    _isMapLoading = false;
                    _hasInitError = true;
                  });

                  _showErrorDialog('Map Initialization Failed', errorMessage);
                } else {
                  // For other errors, just hide loading
                  setState(() {
                    _isMapLoading = false;
                  });
                }
              },
              onRenderComplete: (site) {
                debugPrint('🏢 Site ID: ${site.id ?? 'NULL'}');

                // Hide loading indicator, store site data, and get current floor from map
                setState(() {
                  _isMapLoading = false;
                  _currentSite = site;

                  // Current floor will be set via onGetCurrentFloor callback
                });

                // Initial floor viewport will be applied via onGetCurrentFloor callback
              },
              onViewChange: (viewOptions) {
                // debugPrint('🗺️ View changed: $viewOptions');
              },
              onFloorChanged: (floor) {
                debugPrint('🏢 Floor changed: $floor');

                // Update selected floor when floor switch is complete
                setState(() {
                  _selectedFloor = floor;
                });

                // Apply the floor's viewport configuration
                _applyFloorViewport(floor);
              },
              onAppDataLoaded: () {
                debugPrint('App data loaded ');

                // Check availability first
                final categoriesAvailable =
                    _mapViewKey.currentState?.areCategoriesAvailable() ?? false;
                final locationsAvailable =
                    _mapViewKey.currentState?.areLocationsAvailable() ?? false;
                final amenityTypesAvailable =
                    _mapViewKey.currentState?.areAmenityTypesAvailable() ??
                    false;

                debugPrint('📊 Categories available: $categoriesAvailable');
                debugPrint('📊 Locations available: $locationsAvailable');
                debugPrint(
                  '📊 Amenity types available: $amenityTypesAvailable',
                );

                // Get data counts from the map view
                final categories =
                    _mapViewKey.currentState?.getCategories() ?? [];
                final locations =
                    _mapViewKey.currentState?.getLocations() ?? [];
                final amenityTypes =
                    _mapViewKey.currentState?.getAvailableAmenityTypes() ?? [];

                debugPrint('📊 Categories count: ${categories.length}');
                debugPrint('📊 Locations count: ${locations.length}');
                debugPrint('📊 Amenity types count: ${amenityTypes.length}');
              },
              onLocationsSelected: (locations) {
                debugPrint(
                  '🎯 onLocationsSelected callback triggered with ${locations.length} locations',
                );

                // SDK has already validated locations, so we can trust the data
                if (locations.isNotEmpty) {
                  final firstLocation = locations.first;

                  debugPrint(
                    '🎯 Processing location: ${firstLocation.name} (${firstLocation.id})',
                  );
                  debugPrint(
                    '🎯 Current selected location: ${_selectedLocation?.id}',
                  );
                  debugPrint(
                    '🎯 Location details currently shown: $_showLocationDetails',
                  );

                  // Check if this is the same location already selected to avoid duplicate processing
                  if (_selectedLocation?.id == firstLocation.id &&
                      _showLocationDetails) {
                    debugPrint(
                      '📍 Location already selected and details shown, skipping: ${firstLocation.name}',
                    );
                    return;
                  }

                  // Show location details card - this is triggered by SDK after map selection
                  setState(() {
                    _selectedLocation = firstLocation;
                    _showLocationDetails = true;
                  });

                  debugPrint(
                    '📍 Location selected from map via SDK callback: ${firstLocation.name}',
                  );
                  debugPrint('🎯 Location details card displayed');
                } else {
                  debugPrint('📍 No valid locations received from SDK');
                }
              },
              onGetRoute: (segments) {
                debugPrint(
                  '🛤️ Route received from SDK: ${segments.length} segments',
                );
                _routeManager.handleRouteResult(segments);
              },
            ),

          // Empty state when init error occurs
          if (_hasInitError)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Map Unavailable',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Loading overlay
          if (_isMapLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.9),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading Map...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Floor Switcher - Show when site data is available
          if (_currentSite != null && !_isMapLoading && !_hasInitError)
            FloorSwitcher(
              site: _currentSite,
              selectedFloor: _selectedFloor,
              isExpanded: _isFloorSwitcherExpanded,
              onFloorSelected: (floor) async {
                debugPrint(
                  '🏢 Floor selected: ${floor.displayName} (ID: ${floor.id})',
                );

                // Block call if selecting the same floor
                if (_selectedFloor?.id == floor.id) {
                  debugPrint(
                    '🏢 Floor already selected, blocking duplicate call',
                  );
                  return;
                }

                try {
                  // Call SDK to switch floor
                  await _mapViewKey.currentState?.selectFloor(floor);
                  debugPrint('🏢 Floor switch command sent successfully');

                  // Apply the floor's viewport configuration immediately
                  // Note: This will also be called via onFloorChanged callback,
                  // but calling it here ensures immediate viewport update
                  await _applyFloorViewport(floor);
                } catch (e) {
                  debugPrint('🏢 Floor switch failed: $e');
                  // Don't update UI state if SDK call failed
                  return;
                }
              },
              onExpansionChanged: (isExpanded) {
                setState(() {
                  _isFloorSwitcherExpanded = isExpanded;
                });
              },
            ),

          // Search Widget - Show when search is active
          if (_showSearchWidget)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false, // Don't add bottom safe area padding
                  child: Padding(
                    padding: const EdgeInsets.all(
                      16,
                    ), // Consistent padding on all sides
                    child: BCLocationSearchWidget(
                      key: _searchWidgetKey,
                      mode: _searchMode,
                      onLocationSelected: _onLocationSelected,
                      onSearchRequested: _performLocationSearch,
                      onSearchCanceled: () {
                        debugPrint('🚫 Search canceled by user');
                        setState(() {
                          _resetSearchWidgetToDefault();
                          _forceSearchWidgetRebuild();
                        });
                        // Clear map selections when search is canceled
                        _clearMapSelections();
                      },
                      maxResultsHeight:
                          MediaQuery.of(context).size.height * 0.5,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets
                          .zero, // Remove internal padding since we handle it here
                      initialDestinationValue: _navigationDestination,
                      onSearchModeChanged: _onSearchModeChanged,
                    ),
                  ),
                ),
              ),
            ),

          // Location Details Modal - Show when a location is selected
          if (_showLocationDetails && _selectedLocation != null)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: LocationDetailsModal(
                location: _selectedLocation!,
                onClose: () {
                  setState(() {
                    _showLocationDetails = false;
                    _selectedLocation = null;
                    // Reset search widget to default state when location details are closed
                    _resetSearchWidgetToDefault();
                  });
                  // Clear map selections when location details modal is closed
                  _clearMapSelections();
                },
                onNavigate: _onNavigateToLocation,
              ),
            ),

          // Route Display Modal - Show when route is calculated
          if (_showRoute && _routeSegments.isNotEmpty)
            RouteDisplayModal(
              routeSegments: _routeSegments,
              startLocationName: _routeStartName,
              endLocationName: _routeEndName,
              mapViewKey: _mapViewKey, // Pass mapViewKey for SDK integration
              onStepSelected: (step) {
                // This callback is now handled internally by RouteDisplayModal
                // but we can still add any additional logic here if needed
                debugPrint('🎯 Step selected via callback: ${step.reference}');
              },
              onShowRouteSegment: (segmentIndex) async {
                debugPrint('🛤️ Showing route segment: $segmentIndex');
                try {
                  await _mapViewKey.currentState?.showRoute(segmentIndex);
                  debugPrint('✅ Route segment $segmentIndex displayed on map');
                } catch (e) {
                  debugPrint(
                    '❌ Failed to show route segment $segmentIndex: $e',
                  );
                }
              },
              onDismiss: () async {
                debugPrint(
                  '🚫 Route modal dismissed - clearing route from map',
                );

                // Clear route visualization from map
                try {
                  await _mapViewKey.currentState?.clearRoute();
                  debugPrint('✅ Route cleared from map successfully');
                } catch (e) {
                  debugPrint('⚠️ Failed to clear route from map: $e');
                }

                setState(() {
                  _showRoute = false;
                  _routeSegments.clear();
                  // Reset search widget to default state when route is dismissed
                  _resetSearchWidgetToDefault();
                  _forceSearchWidgetRebuild();
                });
              },
            ),

          // Route calculation loading overlay
          if (_isCalculatingRoute)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Calculating Route...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onSplashComplete: _onSplashComplete);
    }

    return const MyHomePage(title: 'Flutter Demo');
  }
}
