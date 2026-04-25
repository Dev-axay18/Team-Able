import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/hospital_provider.dart';
import '../../core/models/hospital_model.dart';
import 'package:latlong2/latlong.dart';
import 'full_screen_hospital_map.dart';

class HospitalsScreen extends StatefulWidget {
  final LatLng currentLocation;

  const HospitalsScreen({
    super.key,
    required this.currentLocation,
  });

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  bool _showMapView = false;
  gmaps.GoogleMapController? _mapController;
  LatLng _currentLocation;

  _HospitalsScreenState() : _currentLocation = const LatLng(19.0760, 72.8777);

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.currentLocation;
    _startLocationTracking();
    // Fetch hospitals when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HospitalProvider>().fetchNearbyHospitals(
            _currentLocation.latitude,
            _currentLocation.longitude,
            radiusKm: 5.0,
          );
    });
  }

  void _startLocationTracking() async {
    try {
      // Check permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }

      // Start location stream
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) {
          if (mounted) {
            setState(() {
              _currentLocation = LatLng(position.latitude, position.longitude);
            });
          }
        },
      );
    } catch (e) {
      print('Error tracking location: $e');
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openMaps(double lat, double lon, String name) async {
    final Uri launchUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildMapView(List<HospitalModel> hospitals) {
    final userLocation = gmaps.LatLng(
      _currentLocation.latitude,
      _currentLocation.longitude,
    );
    
    final markers = <gmaps.Marker>{};
    
    // Add user location marker (BLUE)
    markers.add(
      gmaps.Marker(
        markerId: const gmaps.MarkerId('user_location'),
        position: userLocation,
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueBlue),
        infoWindow: gmaps.InfoWindow(
          title: '📍 Your Location',
          snippet: 'Lat: ${_currentLocation.latitude.toStringAsFixed(4)}, Lng: ${_currentLocation.longitude.toStringAsFixed(4)}',
        ),
      ),
    );

    // Add hospital markers (RED)
    for (var hospital in hospitals) {
      markers.add(
        gmaps.Marker(
          markerId: gmaps.MarkerId('hospital_${hospital.id}'),
          position: gmaps.LatLng(hospital.latitude, hospital.longitude),
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueRed),
          infoWindow: gmaps.InfoWindow(
            title: hospital.name,
            snippet: hospital.distance != null 
                ? '${hospital.distance!.toStringAsFixed(1)} km away'
                : null,
          ),
          onTap: () {
            _showHospitalDetails(hospital);
          },
        ),
      );
    }

    // Add circle around user (2km radius)
    final circles = <gmaps.Circle>{
      gmaps.Circle(
        circleId: const gmaps.CircleId('user_zone'),
        center: userLocation,
        radius: 2000, // 2km
        fillColor: const Color(0xFF1565C0).withOpacity(0.1),
        strokeColor: const Color(0xFF1565C0),
        strokeWidth: 2,
      ),
    };

    return Stack(
      children: [
        // Google Map
        gmaps.GoogleMap(
          initialCameraPosition: gmaps.CameraPosition(
            target: userLocation,
            zoom: 13.0,
          ),
          onMapCreated: (gmaps.GoogleMapController controller) {
            _mapController = controller;
          },
          markers: markers,
          circles: circles,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        
        // Maximize button (top right)
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'maximize',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenHospitalMap(
                    currentLat: _currentLocation.latitude,
                    currentLng: _currentLocation.longitude,
                    hospitals: hospitals,
                  ),
                ),
              );
            },
            child: const Icon(
              Icons.fullscreen,
              color: Color(0xFF1565C0),
            ),
          ),
        ),
        
        // My location button (bottom right)
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'my_location',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () {
              _mapController?.animateCamera(
                gmaps.CameraUpdate.newLatLngZoom(userLocation, 14.0),
              );
            },
            child: const Icon(
              Icons.my_location,
              color: Color(0xFF1565C0),
            ),
          ),
        ),
        
        // Debug info (bottom left)
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(8),
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
                  '📍 Your Location',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                Text(
                  'Lat: ${_currentLocation.latitude.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 10),
                ),
                Text(
                  'Lng: ${_currentLocation.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${hospital.distance!.toStringAsFixed(1)} km away',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _openMaps(
                            hospital.latitude,
                            hospital.longitude,
                            hospital.name,
                          );
                        },
                        icon: const Icon(Icons.directions_rounded, size: 18),
                        label: const Text('Directions'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _makePhoneCall(hospital.emergencyPhone ?? hospital.phone ?? '');
                        },
                        icon: const Icon(Icons.phone_rounded, size: 18),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nearby Hospitals',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showMapView ? Icons.list_rounded : Icons.map_rounded,
              color: AppTheme.primaryColor,
            ),
            onPressed: () {
              setState(() {
                _showMapView = !_showMapView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
            onPressed: () {
              context.read<HospitalProvider>().fetchNearbyHospitals(
                    _currentLocation.latitude,
                    _currentLocation.longitude,
                    radiusKm: 5.0,
                  );
            },
          ),
        ],
      ),
      body: Consumer<HospitalProvider>(
        builder: (context, provider, child) {
          if (provider.status == HospitalStatus.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Finding hospitals near you...',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.status == HospitalStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppTheme.errorColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage ?? 'Failed to load hospitals',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.fetchNearbyHospitals(
                          _currentLocation.latitude,
                          _currentLocation.longitude,
                          radiusKm: 5.0,
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.hospitals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_hospital_outlined,
                      size: 64,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hospitals found within 5km',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Info banner
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Found ${provider.hospitals.length} hospitals within 5km radius',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Map or List view
              Expanded(
                child: _showMapView
                    ? _buildMapView(provider.hospitals)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: provider.hospitals.length,
                        itemBuilder: (context, index) {
                          final hospital = provider.hospitals[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _HospitalCard(
                              hospital: hospital,
                              onCall: () => _makePhoneCall(hospital.emergencyPhone ?? hospital.phone ?? ''),
                              onDirections: () => _openMaps(
                                hospital.latitude,
                                hospital.longitude,
                                hospital.name,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final HospitalModel hospital;
  final VoidCallback onCall;
  final VoidCallback onDirections;

  const _HospitalCard({
    required this.hospital,
    required this.onCall,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (hospital.rating != null) ...[
                          const Icon(
                            Icons.star_rounded,
                            color: AppTheme.warningColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hospital.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (hospital.distance != null) ...[
                          const Icon(
                            Icons.location_on_rounded,
                            color: AppTheme.primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${hospital.distance!.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Type badge
          if (hospital.type != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                hospital.type!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.successColor,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hospital.address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Features
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (hospital.hasEmergency)
                _FeatureChip(
                  icon: Icons.emergency_rounded,
                  label: 'Emergency',
                  color: AppTheme.errorColor,
                ),
              if (hospital.hasAmbulance)
                _FeatureChip(
                  icon: Icons.local_taxi_rounded,
                  label: 'Ambulance',
                  color: AppTheme.primaryColor,
                ),
              if (hospital.hasICU)
                _FeatureChip(
                  icon: Icons.medical_services_rounded,
                  label: 'ICU',
                  color: AppTheme.warningColor,
                ),
              if (hospital.available24x7)
                _FeatureChip(
                  icon: Icons.access_time_rounded,
                  label: '24x7',
                  color: AppTheme.successColor,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDirections,
                  icon: const Icon(Icons.directions_rounded, size: 18),
                  label: const Text('Directions'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
