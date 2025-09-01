# Becomap WebView Integration API

A complete reference for integrating Becomap WebView with native mobile applications. This document covers all public methods, parameters, callback events, error cases, and validation rules.

---

## Table of Contents
- [Initialization](#initialization)
- [Public Methods](#public-methods)
  - [Data Retrieval](#data-retrieval)
  - [Selection & Navigation](#selection--navigation)
  - [Viewport Control](#viewport-control)
  - [Search](#search)
  - [Routing](#routing)
  - [System & Utility](#system--utility)
- [Callback Events](#callback-events)
- [Error Cases](#error-cases)
- [Parameter Validation](#parameter-validation)
- [Integration Example](#integration-example)
- [Message Format](#message-format)
- [Native Bridge](#native-bridge)

---

## Initialization

### `init(siteOptions)`
Initializes the map view.

**Parameters:**
- `siteOptions` (object, required):
  - `clientId` (string, required)
  - `clientSecret` (string, required)
  - `siteIdentifier` (string, required)

**Errors:**
- Invalid site options
- Map container not found
- SDK load timeout
- Site data load failure

### `cleanup()`
Cleans up all resources, listeners, and state.

---

## Public Methods

### Data Retrieval

#### `getCurrentFloor()`
Returns the current floor object.
- **Callback:** `onGetCurrentFloor`
- **Errors:** MapView not initialized, Application destroyed

#### `getCategories()`
Returns an array of location categories.
- **Callback:** `onGetCategories`
- **Errors:** MapView not initialized

#### `getLocations()`
Returns an array of all locations.
- **Callback:** `onGetLocations`
- **Errors:** MapView not initialized

#### `getAmenityTypes()`
Returns an array of amenity types.
- **Callback:** `onGetAmenityTypes`
- **Errors:** MapView not initialized

#### `getSessionId()`
Returns the current session ID.
- **Callback:** `onGetSessionId`
- **Errors:** MapView not initialized

#### `getHappenings(type)`
Returns an array of events/happenings.
- `type` (string, optional): Event type filter
- **Callback:** `onGetHappenings`
- **Errors:** MapView not initialized

#### `getEventSuggestions(sessionId, answers)`
Returns event suggestions based on session and answers.
- `sessionId` (string, required)
- `answers` (array, required)
- **Callback:** `onGetEventSuggestions`
- **Errors:** MapView not initialized

---

### Selection & Navigation

#### `selectFloorWithId(floorId)`
Selects a floor by ID.
- `floorId` (string|number, required)
- **Errors:** MapView not initialized, Invalid floor ID

#### `selectLocationWithId(locationId)`
Selects a location by ID.
- `locationId` (string|number, required)
- **Errors:** MapView not initialized, Invalid location ID

#### `selectAmenities(type)`
Selects amenities by type.
- `type` (string, required)
- **Errors:** MapView not initialized, Invalid type

#### `clearSelection()`
Clears all selections.
- **Errors:** MapView not initialized

#### `focusTo(location, zoom, bearing, pitch)`
Focuses the camera to a location.
- `location` (object, required)
- `zoom` (number, optional, 1-25)
- `bearing` (number, optional, 0-360)
- `pitch` (number, optional, 0-60)
- **Callback:** `onFocusToError` (on error)
- **Errors:** Invalid parameters, MapView not initialized

---

### Viewport Control

#### `updateZoom(zoom)`
Sets the zoom level.
- `zoom` (number, required, 1-25)
- **Errors:** MapView not initialized, Value out of range

#### `updatePitch(pitch)`
Sets the pitch angle.
- `pitch` (number, required, 0-60)
- **Errors:** MapView not initialized, Value out of range

#### `updateBearing(bearing)`
Sets the bearing angle.
- `bearing` (number, required, 0-360)
- **Errors:** MapView not initialized, Value out of range

#### `enableMultiSelection(val)`
Enables or disables multi-selection.
- `val` (boolean, required)
- **Errors:** MapView not initialized

#### `setBounds(sw, ne)`
Sets the map bounds.
- `sw` (object, required): Southwest coordinate
- `ne` (object, required): Northeast coordinate
- **Errors:** MapView not initialized

#### `setViewport(options)`
Sets the viewport with options.
- `options` (object, required)
- **Errors:** MapView not initialized

#### `resetDefaultViewport(options)`
Resets the viewport to default.
- `options` (object, required)
- **Errors:** MapView not initialized

---

### Search

#### `searchForLocations(query, callbackId)`
Searches for locations.
- `query` (string, required, max 100 chars)
- `callbackId` (string, required)
- **Callback:** `onSearchForLocations`
- **Errors:** Missing/invalid parameters, Search method not available

#### `searchForCategories(query, callbackId)`
Searches for categories.
- `query` (string, required)
- `callbackId` (string, required)
- **Callback:** `onSearchForCategories`
- **Errors:** Search method not available

---

### Routing

#### `getRoute(startID, goalID, waypoints, routeOptions)`
Calculates a route.
- `startID` (string|number, required)
- `goalID` (string|number, required)
- `waypoints` (array, optional, max 10)
- `routeOptions` (object, optional)
- **Callback:** `onGetRoute`, `onGetRouteError`
- **Errors:** Invalid parameters, No route found, Route data invalid

#### `showRoute(segmentOrderIndex?)`
Shows a route or a specific segment.
- `segmentOrderIndex` (number, optional)
- **Callback:** `onShowRouteSuccess`, `onShowRouteError`
- **Errors:** Route controller not available, Invalid segment index, No segments

#### `showStep(step)`
Shows a specific route step.
- `step` (number, required)
- **Errors:** MapView not initialized, Invalid step

#### `clearAllRoutes()`
Clears all displayed routes.
- **Errors:** MapView not initialized

---

### System & Utility

#### `getAppState()`
Returns the current application state.
- **Callback:** `onGetAppState`

#### `healthCheck()`
Returns health and connectivity status.
- **Callback:** `onHealthCheck`

#### `recoverFromError()`
Attempts to recover from an error state.
- **Callback:** `onErrorRecovery`

#### `getDebugInfo()`
Returns debug information.
- **Callback:** `onGetDebugInfo`

---

## Callback Events

| Event Name              | When Fired                        | Payload Example                  |
|------------------------|-----------------------------------|----------------------------------|
| onRenderComplete       | Map is ready                      | `{ site: { ... } }`              |
| onViewChange           | View changed                      | `{ viewOptions: { ... } }`       |
| onLocationSelect       | Location selected                  | `{ locations: [ ... ] }`         |
| onFloorSwitch          | Floor switched                     | `{ floor: { ... } }`             |
| onStepLoad             | Route step loaded                  | `{ step: { ... } }`              |
| onWalkthroughEnd       | Navigation ended                   | `{}`                             |
| onGetCurrentFloor      | Floor data returned                | `{ ... }`                        |
| onGetCategories        | Categories array                   | `[ ... ]`                        |
| onGetLocations         | Locations array                    | `[ ... ]`                        |
| onGetAmenityTypes      | Amenity types array                | `[ ... ]`                        |
| onGetSessionId         | Session ID                         | `"session-id"`                   |
| onGetHappenings        | Events array                       | `[ ... ]`                        |
| onGetEventSuggestions  | Suggestions array                  | `[ ... ]`                        |
| onSearchForLocations   | Location search results            | `{ callbackId, results, error? }`|
| onSearchForCategories  | Category search results            | `{ callbackId, results, error? }`|
| onGetRoute             | Route data                         | `[ ... ]`                        |
| onShowRouteSuccess     | Route shown                        | `{ operation, segmentIndex }`     |
| onGetRouteError        | Route calculation failed           | `{ operation, error }`           |
| onShowRouteError       | Show route failed                  | `{ operation, error }`           |
| onFocusToError         | Focus failed                       | `{ operation, error }`           |
| onError                | General error                      | `{ operation, error }`           |
| onHealthCheck          | Health status                      | `{ ... }`                        |
| onGetAppState          | App state                          | `{ appState, hasMapView, hasSite }`|
| onErrorRecovery        | Recovery status                    | `{}`                             |
| onGetDebugInfo         | Debug data                         | `{ ... }`                        |
| onCleanupComplete      | Cleanup done                       | `{}`                             |

---

## Error Cases

### Initialization
- Invalid site options
- Map container not found
- SDK load timeout
- Site data load failure

### Validation
- Missing required parameters
- Invalid parameter types
- Values out of range
- Invalid location/floor IDs
- Too many waypoints (max 10)
- Start and goal locations cannot be the same

### Network
- API request failures
- Connection timeouts
- Authentication errors

### Bridge Communication
- Native bridge unavailable
- Message send failures
- Queue overflow

### Routing
- No route found
- Invalid start/goal locations
- Route data corruption
- Invalid segment index
- No route segments available

### Application State
- MapView not initialized
- Application destroyed
- Invalid app state

**Example error payload:**
```json
{
  "operation": "getRoute",
  "error": "No route found between specified locations"
}
```

---

## Parameter Validation

- **Required:** If a parameter is required and missing, an error is returned.
- **Type:** If a parameter is of the wrong type, an error is returned.
- **Range:**
  - `zoom`: 1-25
  - `bearing`: 0-360
  - `pitch`: 0-60
  - `waypoints`: max 10
- **Max Length:**
  - `query` (search): 100 characters

**Validation error example:**
```json
{
  "operation": "focusTo",
  "error": "zoom out of valid range"
}
```

---

## Integration Example

```javascript
// 1. Initialize
init({
  clientId: "your-client-id",
  clientSecret: "your-secret",
  siteIdentifier: "site-id"
});

// 2. Wait for onRenderComplete event
// 3. Use public methods
getLocations();
```

---

## Message Format

All messages sent to the native bridge follow this format:
```json
{
  "type": "onLocationSelect",
  "payload": { "locations": [ ... ] },
  "timestamp": 1234567890
}
```

---

## Native Bridge
- **iOS:** `window.webkit.messageHandlers.jsHandler`
- **Android:** `window.jsHandler.postMessage`

---

For further details, see the code in `public/index.html` or contact the SDK maintainers.
