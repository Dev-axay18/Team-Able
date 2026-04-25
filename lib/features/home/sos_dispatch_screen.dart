import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/services/cpin_service.dart';

/// Full SOS dispatch screen shown after CPIN is verified.
/// Shows: allocated ambulance number, driver, hospital, live map.
class SosDispatchScreen extends StatefulWidget {
  final SosSession session;
  final LatLng currentLocation;
  final VoidCallback onCancel;

  const SosDispatchScreen({
    super.key,
    required this.session,
    required this.currentLocation,
    required this.onCancel,
  });

  @override
  State<SosDispatchScreen> createState() => _SosDispatchScreenState();
}

class _SosDispatchScreenState extends State<SosDispatchScreen> {
  // 0 = searching  1 = allocated  2 = en route
  int _stage = 0;
  Timer? _stageTimer;
  GoogleMapController? _mapController;

  // ── Auto-allocated ambulance (mock, nearest to user) ──────────────────────
  static const _ambulanceNo     = 'MH-01-AM-4291';
  static const _driverName      = 'Ravi Kumar';
  static const _driverPhone     = '+91 98765 11223';
  static const _ambulanceType   = 'Advanced Life Support (ALS)';
  static const _ambulanceEta    = 4; // minutes

  // ── Auto-allocated hospital (nearest with emergency) ──────────────────────
  static const _hospitalName    = 'Apollo Hospital';
  static const _hospitalAddress = 'Parsik Hill Road, CBD Belapur, Navi Mumbai';
  static const _hospitalPhone   = '+91 22 3989 8901';
  static const _hospitalDist    = '2.3 km';
  static const _hospitalEta     = 6; // minutes
  static const _hospitalBeds    = '12 ICU beds available';
  static const _hospitalSpec    = 'Trauma & Emergency Care';

  @override
  void initState() {
    super.initState();
    // Stage 0 → 1 after 2 s  (resources found)
    _stageTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _stage = 1);
      // Stage 1 → 2 after 3 s  (en route)
      _stageTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _stage = 2);
      });
    });
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Color get _stageColor => const [
    Color(0xFFFFA726),
    Color(0xFF1565C0),
    Color(0xFF43A047),
  ][_stage];

  IconData get _stageIcon => const [
    Icons.search_rounded,
    Icons.local_shipping_rounded,
    Icons.directions_car_rounded,
  ][_stage];

  String get _stageTitle => const [
    'Finding nearest resources...',
    'Ambulance & Hospital Allocated!',
    'Ambulance En Route to You',
  ][_stage];

  String get _stageSub => const [
    'Scanning hospitals & ambulances near you',
    'Help confirmed — ambulance is on the way',
    'Driver is navigating to your live location',
  ][_stage];

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildStatusCard(),
                    const SizedBox(height: 14),
                    _buildProgressRow(),
                    const SizedBox(height: 14),
                    _buildLiveMap(),
                    const SizedBox(height: 14),
                    if (_stage == 0) _buildSearchingCard(),
                    if (_stage >= 1) ...[
                      _buildAmbulanceCard(),
                      const SizedBox(height: 12),
                      _buildHospitalCard(),
                    ],
                    const SizedBox(height: 12),
                    _buildLocationCard(),
                    const SizedBox(height: 20),
                    _buildButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: const Color(0xFFD32F2F),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.emergency_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'SOS ACTIVE — Emergency Dispatched',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ID: ${widget.session.sessionId.substring(4, 14)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Status card ───────────────────────────────────────────────────────────
  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Container(
              key: ValueKey(_stage),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _stageColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_stageIcon, color: _stageColor, size: 28),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _stageTitle,
                    key: ValueKey('t$_stage'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _stageSub,
                    key: ValueKey('s$_stage'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress row ──────────────────────────────────────────────────────────
  Widget _buildProgressRow() {
    final labels = ['Searching', 'Allocated', 'En Route'];
    return Row(
      children: List.generate(3, (i) {
        final done   = i < _stage;
        final active = i == _stage;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: done || active
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFFE5E7EB),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: active
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: done || active
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              if (i < 2)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 18),
                    color: i < _stage
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  // ── Live mini-map ─────────────────────────────────────────────────────────
  Widget _buildLiveMap() {
    // Ambulance mock position (slightly north-east of user)
    final ambulanceLoc = LatLng(
      widget.currentLocation.latitude + 0.012,
      widget.currentLocation.longitude + 0.008,
    );
    // Hospital mock position (slightly south-east of user)
    final hospitalLoc = LatLng(
      widget.currentLocation.latitude - 0.015,
      widget.currentLocation.longitude + 0.010,
    );

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('patient'),
        position: widget.currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: '🚨 Your Location'),
      ),
      if (_stage >= 1) ...[
        Marker(
          markerId: const MarkerId('ambulance'),
          position: ambulanceLoc,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: '🚑 Ambulance',
            snippet: _ambulanceNo,
          ),
        ),
        Marker(
          markerId: const MarkerId('hospital'),
          position: hospitalLoc,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(
            title: '🏥 Apollo Hospital',
            snippet: '2.3 km away',
          ),
        ),
      ],
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.currentLocation,
                zoom: 14.0,
              ),
              onMapCreated: (c) {
                _mapController = c;
                c.animateCamera(
                  CameraUpdate.newLatLngZoom(widget.currentLocation, 14.0),
                );
              },
              markers: markers,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
            ),
            // LIVE badge
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emergency_rounded, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'LIVE SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Legend
            if (_stage >= 1)
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LegendDot(color: Color(0xFFD32F2F), label: 'You'),
                      SizedBox(height: 3),
                      _LegendDot(color: Color(0xFF1565C0), label: 'Ambulance'),
                      SizedBox(height: 3),
                      _LegendDot(color: Color(0xFF43A047), label: 'Hospital'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Searching card (stage 0) ──────────────────────────────────────────────
  Widget _buildSearchingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD54F)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFFFFA726),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Scanning nearest ambulances and hospitals...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF57C00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Ambulance card ────────────────────────────────────────────────────────
  Widget _buildAmbulanceCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Ambulance Allocated',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '$_ambulanceEta min ETA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Ambulance number — most prominent
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'AMBULANCE NUMBER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1565C0),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _ambulanceNo,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1565C0),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _infoRow(Icons.person_outline, 'Driver', _driverName),
                const SizedBox(height: 8),
                _infoRow(Icons.phone_outlined, 'Contact', _driverPhone),
                const SizedBox(height: 8),
                _infoRow(Icons.medical_services_outlined, 'Type', _ambulanceType),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Hospital card ─────────────────────────────────────────────────────────
  Widget _buildHospitalCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF43A047).withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF43A047),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_hospital_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Hospital Allocated',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    _hospitalDist,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Hospital name — most prominent
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'ALLOCATED HOSPITAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF43A047),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        _hospitalName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        _hospitalSpec,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF43A047),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _infoRow(Icons.location_on_outlined, 'Address', _hospitalAddress),
                const SizedBox(height: 8),
                _infoRow(Icons.phone_outlined, 'Emergency', _hospitalPhone),
                const SizedBox(height: 8),
                _infoRow(Icons.bed_outlined, 'Availability', _hospitalBeds),
                const SizedBox(height: 8),
                _infoRow(Icons.access_time_rounded, 'ETA to Hospital',
                    '$_hospitalEta minutes'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Location card ─────────────────────────────────────────────────────────
  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD32F2F).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded,
              color: Color(0xFFD32F2F), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your live location is being shared',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD32F2F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lat: ${widget.currentLocation.latitude.toStringAsFixed(6)}  '
                  'Lng: ${widget.currentLocation.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          // Pulsing dot
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF43A047),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  // ── Buttons ───────────────────────────────────────────────────────────────
  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              widget.onCancel();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.cancel_outlined, size: 16),
            label: const Text('Cancel SOS'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD32F2F),
              side: const BorderSide(color: Color(0xFFD32F2F)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check_circle_outline,
                size: 16, color: Colors.white),
            label: const Text(
              'Got It',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF43A047),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Shared info row ───────────────────────────────────────────────────────
  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
              fontSize: 12, color: Color(0xFF6B7280)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Small legend dot ──────────────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 8),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
