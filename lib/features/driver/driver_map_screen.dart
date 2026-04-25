import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  
  // Mumbai Central coordinates as default
  static const LatLng _defaultLocation = LatLng(19.0760, 72.8777);
  
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _addMockEmergencyCases();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    print('🔍 Starting location initialization...');
    
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('📍 Location service enabled: $serviceEnabled');
    
    if (!serviceEnabled) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Please enable location services', isError: true);
      }
      return;
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    print('🔐 Current permission: $permission');
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print('🔐 Permission after request: $permission');
      
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackBar('Location permission denied', isError: true);
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showPermissionDialog();
      }
      return;
    }

    // Get current location
    await _getCurrentLocation();
    
    // Start listening to location updates
    _startLocationStream();
  }

  void _startLocationStream() {
    print('🎯 Starting location stream...');
    
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        print('📍 New position: ${position.latitude}, ${position.longitude}');
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
          _updateDriverMarker(position);
        }
      },
      onError: (error) {
        print('❌ Location stream error: $error');
      },
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission is permanently denied. Please enable it in app settings to use live tracking.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      print('📍 Getting current location...');
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      print('✅ Got location: ${position.latitude}, ${position.longitude}');
      print('   Accuracy: ${position.accuracy}m');
      print('   Altitude: ${position.altitude}m');

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });

        // Add/update driver marker
        _updateDriverMarker(position);

        // Move camera to current location
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            15.0,
          ),
        );
        
        _showSnackBar('Location found: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}');
      }
    } catch (e) {
      print('❌ Error getting location: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Could not get location: $e', isError: true);
      }
    }
  }

  void _updateDriverMarker(Position position) {
    setState(() {
      // Remove old markers
      _markers.removeWhere((m) => m.markerId.value == 'driver_location');
      _circles.removeWhere((c) => c.circleId.value == 'driver_zone');
      
      // Add new marker
      _markers.add(
        Marker(
          markerId: const MarkerId('driver_location'),
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Your Location',
            snippet: 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}',
          ),
        ),
      );

      // Add circle
      _circles.add(
        Circle(
          circleId: const CircleId('driver_zone'),
          center: LatLng(position.latitude, position.longitude),
          radius: 2000, // 2km radius
          fillColor: const Color(0xFF1565C0).withOpacity(0.1),
          strokeColor: const Color(0xFF1565C0),
          strokeWidth: 2,
        ),
      );
    });
  }

  void _addDriverMarker(Position position) {
    _markers.add(
      Marker(
        markerId: const MarkerId('driver_location'),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'Your Location',
          snippet: 'Ambulance 42-B',
        ),
      ),
    );

    // Add circle around driver
    _circles.add(
      Circle(
        circleId: const CircleId('driver_zone'),
        center: LatLng(position.latitude, position.longitude),
        radius: 2000, // 2km radius
        fillColor: const Color(0xFF1565C0).withOpacity(0.1),
        strokeColor: const Color(0xFF1565C0),
        strokeWidth: 2,
      ),
    );
  }

  void _addMockEmergencyCases() {
    // Mock emergency case locations in Mumbai
    final emergencyCases = [
      {
        'id': 'case_1',
        'title': 'Cardiac Arrest',
        'location': LatLng(19.0896, 72.8656),
        'priority': 'critical',
      },
      {
        'id': 'case_2',
        'title': 'Patient Transfer',
        'location': LatLng(19.0644, 72.8700),
        'priority': 'routine',
      },
      {
        'id': 'case_3',
        'title': 'Accident',
        'location': LatLng(19.0825, 72.8900),
        'priority': 'urgent',
      },
    ];

    for (var case_ in emergencyCases) {
      _markers.add(
        Marker(
          markerId: MarkerId(case_['id'] as String),
          position: case_['location'] as LatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            case_['priority'] == 'critical'
                ? BitmapDescriptor.hueRed
                : case_['priority'] == 'urgent'
                    ? BitmapDescriptor.hueOrange
                    : BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: case_['title'] as String,
            snippet: 'Tap for details',
          ),
          onTap: () => _showCaseDetails(case_),
        ),
      );
    }
  }

  void _showCaseDetails(Map<String, dynamic> case_) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isPriority = case_['priority'] == 'critical';
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isPriority
                            ? const Color(0xFFEF5350).withOpacity(0.1)
                            : const Color(0xFF43A047).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        case_['priority'].toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isPriority
                              ? const Color(0xFFEF5350)
                              : const Color(0xFF43A047),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  case_['title'] as String,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Emergency location',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToCase(case_['location'] as LatLng);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Navigate',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF1565C0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Decline',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToCase(LatLng destination) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(destination, 16.0),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation started to emergency location'),
        backgroundColor: Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : _defaultLocation,
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: _markers,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
          ),

          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.map_outlined,
                            color: Color(0xFF1565C0),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Live Map',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // My Location Button
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Refresh location button
                FloatingActionButton(
                  heroTag: 'refresh',
                  onPressed: _getCurrentLocation,
                  backgroundColor: Colors.white,
                  mini: true,
                  child: const Icon(
                    Icons.refresh,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 8),
                // My location button
                FloatingActionButton(
                  heroTag: 'location',
                  onPressed: () {
                    if (_currentPosition != null) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          15.0,
                        ),
                      );
                    } else {
                      _getCurrentLocation();
                    }
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.my_location,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ),

          // Loading/Status indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF1565C0),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Getting your location...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Debug info (remove in production)
          if (_currentPosition != null)
            Positioned(
              bottom: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '📍 Your Location:',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(
                      'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(
                      'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
