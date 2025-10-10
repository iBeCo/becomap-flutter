# Becomap Flutter SDK

A Flutter package for integrating Becomap interactive maps into Flutter applications. This package provides a WebView-based implementation that loads Becomap content with a Flutter-friendly interface.

## ⚠️ Authorization Required

**IMPORTANT**: This SDK requires explicit authorization from Beco before use. You must obtain proper licensing and authorization from Beco to use this SDK and access Becomap services.

- **Contact Beco**: [https://becomap.com/contact](https://becomap.com/contact)
- **Maintained by**: Globeco Technologies
- **Authorization**: Required for all usage (development, testing, production)

## Features

- **BCMapView Widget**: A Flutter widget that displays Becomap interactive maps
- **WebView Integration**: Uses webview_flutter for reliable web content display
- **Error Handling**: Built-in error handling and loading states
- **Debug Mode**: Optional debug logging for development
- **Customizable**: Configurable callbacks and URL loading

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  becomap: ^1.1.0
```

Then run:
```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:becomap/becomap.dart';

class MyMapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Becomap')),
      body: BCMapView(
        onMapReady: () {
          print('Map is ready for interaction');
        },
        onError: (error) {
          print('Map error: $error');
        },
      ),
    );
  }
}
```

### Advanced Usage with Custom URL

```dart
BCMapView(
  url: 'https://your-custom-becomap-url.com',
  debugMode: true,
  onMapReady: () {
    // Handle map ready state
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Map loaded successfully!')),
    );
  },
  onError: (error) {
    // Handle errors
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Map Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  },
)
```

## API Reference

### BCMapView

The main widget for displaying Becomap interactive maps with full functionality.

#### Basic Usage

```dart
BCMapView(
  onMapReady: () => print('Map ready'),
  onError: (errorType, errorMessage) => print('Error: $errorType - $errorMessage'),
  onRenderComplete: (site) => print('Site loaded: ${site.id}'),
)
```

#### Advanced Usage with Controller

```dart
final GlobalKey<BCMapViewState> mapKey = GlobalKey<BCMapViewState>();

BCMapView(
  key: mapKey,
  onMapReady: () async {
    // Initialize map with authentication
    await mapKey.currentState?.initialiseMap(initOptions, siteOptions);
  },
  onAppDataLoaded: () async {
    // Search for locations
    final locations = await mapKey.currentState?.searchLocation('coffee');

    // Select a location
    if (locations.isNotEmpty) {
      await mapKey.currentState?.selectLocation(locations.first);
    }
  },
)
```

#### Widget Properties

- `onMapReady` (VoidCallback?): Fired when map is ready for interaction
- `onError` (Function(String errorType, String errorMessage)?): Fired when errors occur
- `onRenderComplete` (Function(BCSite site)?): Fired when site rendering completes
- `onViewChange` (Function(BCViewOptions viewOptions)?): Fired when viewport changes
- `onFloorChanged` (Function(BCMapFloor floor)?): Fired when active floor changes
- `onGetCurrentFloor` (Function(BCMapFloor floor)?): Fired when current floor data is retrieved
- `onAppDataLoaded` (VoidCallback?): Fired when all app data finishes loading
- `onLocationsSelected` (Function(List<BCLocation> locations)?): Fired when locations are selected
- `onGetRoute` (Function(List<BCRouteSegment> segments)?): Fired when route is calculated
- `url` (String?): Custom URL to load (optional)

#### Controller Methods (BCMapViewState)

Access via `GlobalKey<BCMapViewState>`:

```dart
// Map initialization
await mapState.initialiseMap(initOptions, siteOptions);

// Floor management
await mapState.selectFloor(floor);

// Viewport control
await mapState.setViewport(viewOptions);

// Data access
List<BCCategory> categories = mapState.getCategories();
List<BCLocation> locations = mapState.getLocations();
List<String> amenityTypes = mapState.getAvailableAmenityTypes();

// Search functionality
List<BCLocation> results = await mapState.searchLocation('query');
List<BCCategory> categoryResults = await mapState.searchCategory('query');

// Navigation and routing
await mapState.selectLocation(location);
await mapState.getRoute(
  startLocation: start,
  goalLocation: goal,
  routeOptions: options,
);
await mapState.showRoute();
await mapState.showStep(step);

// State management
await mapState.clearRoute();
await mapState.clearSelection();
mapState.clearSelectedLocationState();
```

### Static Methods

```dart
// Enable/disable debug logging
BCMapView.setDebugLoggingEnabled(true);
```

### Data Models

All data models follow the interface pattern:

- **BCSite**: Site information and buildings
- **BCBuilding**: Building details and floors
- **BCMapFloor**: Floor information and navigation
- **BCLocation**: Point of interest data
- **BCCategory**: Location categorization
- **BCRouteSegment**: Route navigation segments
- **BCRouteStep**: Individual route steps
- **BCViewOptions**: Viewport configuration

### Configuration Models

- **BCMapInitOptions**: Authentication and initialization settings
- **BCMapSiteOptions**: Site-specific configuration
- **BCRouteOptions**: Route calculation preferences

## Platform Support

- ✅ **Android**: API 21+ (Android 5.0+)
- ✅ **iOS**: 17.0+ (optimized for latest features)

## Error Handling

The SDK provides comprehensive error handling through callback functions:

```dart
BCMapView(
  onError: (errorType, errorMessage) {
    // Handle different error types
    switch (errorType) {
      case 'network':
        // Handle network connectivity issues
        break;
      case 'authentication':
        // Handle authentication failures
        break;
      case 'initialization':
        // Handle SDK initialization errors
        break;
      default:
        // Handle other errors
        break;
    }
  },
)
```

## Debug Mode

Enable debug logging for development and troubleshooting:

```dart
// Enable debug logging
BCMapView.setDebugLoggingEnabled(true);

// Your BCMapView widget
BCMapView(
  onMapReady: () => print('Map ready with debug logging enabled'),
  // ... other properties
)
```

## Troubleshooting

### Common Issues

1. **iOS build issues**:
   - Ensure iOS 17.0+ deployment target
   - Clean and rebuild: `flutter clean && flutter pub get`

2. **Android build issues**:
   - Verify minSdkVersion 21+
   - Check WebView permissions in AndroidManifest.xml

3. **Authentication errors**:
   - Verify your Becomap API credentials
   - Check that your site identifier is correct
   - Ensure proper authorization from Beco

## License

This project is part of the Becomap SDK suite and requires explicit authorization from Beco for use.
