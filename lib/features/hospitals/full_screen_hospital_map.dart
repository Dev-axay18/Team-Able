import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/hospital_model.dart';
import '../../core/theme/app_theme.dart';

// NOTE: We use google_maps_flutter's LatLng here (NOT latlong2)
// The currentLocation is passed as lat/lng doubles to avoid the conflict

class FullScreenHospitalMap extends StatefulWidget {
  final double currentLat;
  final double currentLng;
  final List<HospitalModel> hospitals;

  const FullScreenHospitalMap({
    super.key,
    required this.currentLat,
    required this.currentLng,
    required this.hospitals,
  });

  @override
  State<FullScreenHospitalMap> createState() => _FullScreenHospitalMapState();
}

class _FullScreenHospitalMapState extends State<FullScreenHospitalMap> {
  GoogleMapController? _mapController;
  double _currentLat = 0;
  double _currentLng = 0;
  bool _isLoading = true;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _currentLat = widget.currentLat;
    _currentLng = widget.currentLng;
    _buildMarkers(_currentLat, _currentLng);
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    await _getCurrentLocation();
    _startLocationStream();
  }

  void _startLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        if (mounted) {
          setState(() {
            _currentLat = position.latitude;
            _currentLng = position.longitude;
          });
          _buildMarkers(position.latitude, position.longitude);
        }
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      if (mounted) {
        setState(() {
          _currentLat = position.latitude;
          _currentLng = position.longitude;
          _isLoading = false;
        });
        _buildMarkers(position.latitude, position.longitude);
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            13.0,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _buildMarkers(double lat, double lng) {
    final Set<Marker> newMarkers = {};
    final Set<Circle> newCircles = {};

    // User location marker (blue)
    newMarkers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: '📍 Your Location',
          snippet: 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}',
        ),
      ),
    );

    // User coverage circle
    newCircles.add(
      Circle(
        circleId: const CircleId('user_zone'),
        center: LatLng(lat, lng),
        radius: 2000,
        fillColor: const Color(0xFF1565C0).withOpacity(0.1),
        strokeColor: const Color(0xFF1565C0),
        strokeWidth: 2,
      ),
    );

    // Hospital markers (red)
    for (var hospital in widget.hospitals) {
      newMarkers.add(
        Marker(
          markerId: MarkerId('hospital_${hospital.id}'),
          position: LatLng(hospital.latitude, hospital.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: hospital.name,
            snippet: hospital.distance != null
                ? '${hospital.distance!.toStringAsFixed(1)} km away'
                : null,
          ),
          onTap: () => _showHospitalDetails(hospital),
        ),
      );
    }

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
      _circles.clear();
      _circles.addAll(newCircles);
    });
  }

  void _showHospitalDetails(HospitalModel hospital) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                if (hospital.distance != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppTheme.primaryColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${hospital.distance!.toStringAsFixed(1)} km away',
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Text(
                  hospital.address,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _openMaps(hospital.latitude, hospital.longitude,
                              hospital.name);
                        },
                        icon: const Icon(Icons.directions_rounded, size: 18),
                        label: const Text('Directions'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _makePhoneCall(
                              hospital.emergencyPhone ?? hospital.phone ?? '');
                        },
                        icon: const Icon(Icons.phone_rounded, size: 18),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  Future<void> _openMaps(double lat, double lon, String name) async {
    final Uri launchUri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(_currentLat, _currentLng),
              zoom: 13.0,
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
                      icon: const Icon(Icons.close, color: Color(0xFF1A1A2E)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                      child: Row(
                        children: [
                          const Icon(Icons.local_hospital_rounded,
                              color: Color(0xFF1565C0), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Nearby Hospitals (${widget.hospitals.length})',
                            style: const TextStyle(
                              fontSize: 15,
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

          // Buttons (bottom right)
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'fs_refresh',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _getCurrentLocation,
                  child: const Icon(Icons.refresh, color: Color(0xFF1565C0)),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'fs_my_location',
                  backgroundColor: Colors.white,
                  onPressed: () {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(_currentLat, _currentLng),
                        14.0,
                      ),
                    );
                  },
                  child: const Icon(Icons.my_location,
                      color: Color(0xFF1565C0)),
                ),
              ],
            ),
          ),

          // Live location info (bottom left)
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
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
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on,
                          color: Color(0xFF1565C0), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Live Location',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Lat: ${_currentLat.toStringAsFixed(5)}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  Text(
                    'Lng: ${_currentLng.toStringAsFixed(5)}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF1565C0)),
                    SizedBox(height: 16),
                    Text(
                      'Getting your location...',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
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
