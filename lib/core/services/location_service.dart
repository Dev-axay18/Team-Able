import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService instance = LocationService._internal();
  LocationService._internal();

  Position? _lastKnownPosition;
  
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission with proper flow
  Future<LocationPermissionStatus> requestPermission() async {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus(
        granted: false,
        message: 'Location services are disabled. Please enable location in your device settings.',
        shouldOpenSettings: true,
      );
    }

    // Check current permission
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus(
          granted: false,
          message: 'Location permission denied. Please grant location access to use this feature.',
          shouldOpenSettings: false,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus(
        granted: false,
        message: 'Location permission permanently denied. Please enable it in app settings.',
        shouldOpenSettings: true,
      );
    }

    // Permission granted
    return LocationPermissionStatus(
      granted: true,
      message: 'Location permission granted',
      shouldOpenSettings: false,
    );
  }

  /// Get current location with permission check
  Future<Position?> getCurrentLocation({
    bool forceRefresh = false,
  }) async {
    try {
      // Check and request permission
      final permissionStatus = await requestPermission();
      if (!permissionStatus.granted) {
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _lastKnownPosition = position;
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return _lastKnownPosition;
    }
  }

  /// Get location stream for real-time tracking
  Stream<Position> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
  }) {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    ) / 1000; // Convert to kilometers
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}

class LocationPermissionStatus {
  final bool granted;
  final String message;
  final bool shouldOpenSettings;

  LocationPermissionStatus({
    required this.granted,
    required this.message,
    required this.shouldOpenSettings,
  });
}
