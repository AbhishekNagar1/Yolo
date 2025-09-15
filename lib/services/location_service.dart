import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const int _updateInterval = 10; // seconds
  static const double _geofenceRadius = 50.0; // meters

  Timer? _locationTimer;
  Position? _currentPosition;
  Function(Position)? _onLocationUpdate;

  // Mock location for testing
  double _mockLat = 28.6139;
  double _mockLng = 77.2090;

  // Check if location services are enabled
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return _currentPosition;
    } catch (e) {
      // Return null if real location fails
      return null;
    }
  }

  // Start location updates
  void startLocationUpdates(Function(Position) onLocationUpdate) {
    _onLocationUpdate = onLocationUpdate;
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(
      const Duration(seconds: _updateInterval),
      (_) async {
        Position? newPosition = await getCurrentLocation();
        if (newPosition != null) {
          _currentPosition = newPosition;
          _onLocationUpdate?.call(_currentPosition!);
          // Print to console as "sent to server"
          print('Location update sent to server: '
              'Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}');
        } else {
          // Use mock location when real location is not available
          print('Using mock location: Lat: $_mockLat, Lng: $_mockLng');
        }
      },
    );
  }

  // Stop location updates
  void stopLocationUpdates() {
    _locationTimer?.cancel();
  }

  // Calculate distance between two points in meters
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000; // 2 * R; R = 6371 km
  }

  // Check if driver is within geofence
  bool isWithinGeofence(double targetLat, double targetLng) {
    if (_currentPosition == null) return false;

    double distance = calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      targetLat,
      targetLng,
    );

    return distance <= _geofenceRadius;
  }

  // For testing: Move mock location
  void moveMockLocation(double lat, double lng) {
    _mockLat = lat;
    _mockLng = lng;
  }

  // Get current position (for UI display)
  Position? get currentPosition => _currentPosition;
  
  // Get mock position
  Position get mockPosition {
    return Position(
      latitude: _mockLat,
      longitude: _mockLng,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }
}