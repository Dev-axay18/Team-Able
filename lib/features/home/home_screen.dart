import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/cpin_service.dart';
import 'ambulance_severity_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // SOS
  late AnimationController _sosController;
  late Animation<double> _sosPulse;
  bool _sosHolding = false;
  Timer? _sosTimer;
  bool _sosActive = false;
  SosSession? _activeSosSession;

  // Location
  LatLng _currentLocation = const LatLng(19.0760, 72.8777); // Mumbai default
  bool _locationLoaded = false;
  bool _highAccuracy = false;
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  String _locationAddress = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _sosController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _sosPulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _sosController, curve: Curves.easeInOut),
    );
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      // Check & request foreground permission first
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDeniedDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionPermanentlyDeniedDialog();
        return;
      }

      // Request background / always-on permission
      if (permission == LocationPermission.whileInUse) {
        await Geolocator.requestPermission();
      }

      // Get last known position instantly for fast first paint
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && mounted) {
        setState(() {
          _currentLocation = LatLng(lastKnown.latitude, lastKnown.longitude);
          _locationLoaded = true;
          _locationAddress =
              '${lastKnown.latitude.toStringAsFixed(5)}, ${lastKnown.longitude.toStringAsFixed(5)}';
        });
        _mapController.move(_currentLocation, 16.0);
      }

      // Then get accurate current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _locationLoaded = true;
          _highAccuracy = position.accuracy < 20;
          _locationAddress =
              '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
        });
        // Animate map to real location with zoom 16
        _mapController.move(_currentLocation, 16.0);
      }

      // Continuous live tracking — always on, every 5m or 3 seconds
      _positionStream = Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 5,
          forceLocationManager: false,
          intervalDuration: const Duration(seconds: 3),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
                'JeevanPath is tracking your location for emergency services.',
            notificationTitle: 'JeevanPath Active',
            enableWakeLock: true,
            notificationIcon:
                AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
          ),
        ),
      ).listen((pos) {
        if (mounted) {
          setState(() {
            _currentLocation = LatLng(pos.latitude, pos.longitude);
            _highAccuracy = pos.accuracy < 20;
            _locationAddress =
                '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
          });
          _mapController.move(_currentLocation, 16.0);
        }
      });
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_off_rounded, color: Color(0xFFD32F2F)),
            SizedBox(width: 8),
            Text('Location Off'),
          ],
        ),
        content: const Text(
          'Location services are disabled. Please enable GPS to use emergency features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0)),
            child: const Text('Open Settings',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_disabled_rounded, color: Color(0xFFD32F2F)),
            SizedBox(width: 8),
            Text('Permission Needed'),
          ],
        ),
        content: const Text(
          'JeevanPath needs location access to dispatch emergency services to your exact location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _initLocation();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0)),
            child: const Text('Allow', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F)),
            SizedBox(width: 8),
            Text('Location Blocked'),
          ],
        ),
        content: const Text(
          'Location permission is permanently denied. Please go to App Settings → Permissions → Location → Set to "Always Allow".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0)),
            child: const Text('Open App Settings',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _onSosHoldStart() {
    setState(() => _sosHolding = true);
    HapticFeedback.heavyImpact();
    _sosTimer = Timer(const Duration(seconds: 3), () {
      _showCPinDialog();
    });
  }

  void _onSosHoldEnd() {
    setState(() => _sosHolding = false);
    _sosTimer?.cancel();
  }

  // ── Step 1: Show C-PIN dialog ─────────────────────────────────────────────
  void _showCPinDialog() {
    HapticFeedback.mediumImpact();
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final List<TextEditingController> pinControllers =
        List.generate(4, (_) => TextEditingController());
    final List<FocusNode> pinFocusNodes =
        List.generate(4, (_) => FocusNode());
    bool isVerifying = false;
    String? errorMsg;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            Future<void> verifyPin() async {
              final entered =
                  pinControllers.map((c) => c.text).join();
              if (entered.length < 4) return;

              setDialogState(() {
                isVerifying = true;
                errorMsg = null;
              });

              final result = await CPinService.instance
                  .verifyPin(user.id, entered);

              if (!ctx.mounted) return;

              switch (result) {
                case CPinResult.success:
                  Navigator.of(ctx).pop();
                  _dispatchAmbulance(user);
                  break;

                case CPinResult.invalid:
                  HapticFeedback.vibrate();
                  for (final c in pinControllers) c.clear();
                  pinFocusNodes[0].requestFocus();
                  setDialogState(() {
                    isVerifying = false;
                    errorMsg = 'Incorrect C-PIN. Please try again.';
                  });
                  break;

                case CPinResult.userNotFound:
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User not found. Please re-login.'),
                      backgroundColor: Color(0xFFD32F2F),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  break;
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Red shield icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFEBEE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Color(0xFFD32F2F),
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Enter C-PIN',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter your 4-digit security PIN\nto dispatch emergency services.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 4 PIN boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) {
                        return Container(
                          width: 56,
                          height: 62,
                          margin: EdgeInsets.only(right: i < 3 ? 12 : 0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: errorMsg != null
                                  ? const Color(0xFFD32F2F)
                                  : pinFocusNodes[i].hasFocus
                                      ? const Color(0xFFD32F2F)
                                      : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: TextField(
                            controller: pinControllers[i],
                            focusNode: pinFocusNodes[i],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A1A2E),
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                            ),
                            onChanged: (val) {
                              setDialogState(() => errorMsg = null);
                              if (val.isNotEmpty && i < 3) {
                                pinFocusNodes[i + 1].requestFocus();
                              }
                              if (val.isEmpty && i > 0) {
                                pinFocusNodes[i - 1].requestFocus();
                              }
                              // Auto verify when all 4 filled
                              final full = pinControllers
                                  .map((c) => c.text)
                                  .join();
                              if (full.length == 4) {
                                verifyPin();
                              }
                            },
                          ),
                        );
                      }),
                    ),

                    // Error message
                    if (errorMsg != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Color(0xFFD32F2F), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            errorMsg!,
                            style: const TextStyle(
                              color: Color(0xFFD32F2F),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Verify button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isVerifying ? null : verifyPin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: isVerifying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white),
                              )
                            : const Text(
                                'Verify & Dispatch',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Cancel
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        setState(() => _sosHolding = false);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // Auto-focus first box
    Future.delayed(const Duration(milliseconds: 300), () {
      if (pinFocusNodes[0].canRequestFocus) {
        pinFocusNodes[0].requestFocus();
      }
    });
  }

  // ── Step 2: Dispatch ambulance after PIN verified ─────────────────────────
  void _dispatchAmbulance(dynamic user) {
    HapticFeedback.vibrate();

    final session = CPinService.instance.createSosSession(
      userId: user.id,
      userName: user.name,
      latitude: _currentLocation.latitude,
      longitude: _currentLocation.longitude,
    );

    setState(() {
      _sosActive = true;
      _activeSosSession = session;
    });

    _showDispatchingDialog();
  }

  // ── Step 3: Show dispatching → driver assigned flow ───────────────────────
  void _showDispatchingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _DispatchingDialog(
          session: _activeSosSession!,
          currentLocation: _currentLocation,
          onCancel: () {
            final user = context.read<AuthProvider>().user;
            if (user != null) {
              CPinService.instance.cancelSos(user.id);
            }
            setState(() {
              _sosActive = false;
              _activeSosSession = null;
            });
            Navigator.of(ctx).pop();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _sosController.dispose();
    _sosTimer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final firstName = user?.name.split(' ').first ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(firstName),
              _buildSOSButton(),
              _buildAmbulanceCard(),
              _buildQuickActions(),
              _buildMapSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top Bar ──────────────────────────────────────────────────────────────
  Widget _buildTopBar(String firstName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Hamburger
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                )
              ],
            ),
            child: const Icon(Icons.menu_rounded,
                color: Color(0xFF1A1A2E), size: 22),
          ),

          // Title
          const Expanded(
            child: Center(
              child: Text(
                'JeevanPath AI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1565C0),
                ),
              ),
            ),
          ),

          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor, width: 2),
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppTheme.primaryColor, size: 22),
          ),
        ],
      ),
    );
  }

  // ── Greeting + SOS ───────────────────────────────────────────────────────
  Widget _buildSOSButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            'Hello, ${context.watch<AuthProvider>().user?.name.split(' ').first ?? 'User'}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const Text(
            'System active and monitoring.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          // SOS Card
          GestureDetector(
            onLongPressStart: (_) => _onSosHoldStart(),
            onLongPressEnd: (_) => _onSosHoldEnd(),
            onLongPressCancel: _onSosHoldEnd,
            child: ScaleTransition(
              scale: _sosPulse,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36),
                decoration: BoxDecoration(
                  color: _sosActive
                      ? const Color(0xFF7B1FA2)
                      : _sosHolding
                          ? const Color(0xFFB71C1C)
                          : const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (_sosActive
                              ? const Color(0xFF7B1FA2)
                              : const Color(0xFFD32F2F))
                          .withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '✱',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _sosActive ? 'SOS ACTIVE' : 'SOS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _sosActive
                          ? 'Ambulance dispatched • Location shared'
                          : _sosHolding
                              ? 'Activating...'
                              : 'Hold for 3 seconds to alert emergency services',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                    if (_sosActive) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          final user = context.read<AuthProvider>().user;
                          if (user != null) {
                            CPinService.instance.cancelSos(user.id);
                          }
                          setState(() {
                            _sosActive = false;
                            _activeSosSession = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.5)),
                          ),
                          child: const Text(
                            'Cancel SOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Ambulance Card ───────────────────────────────────────────────────────
  Widget _buildAmbulanceCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () {
          // Navigate to severity selection screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AmbulanceSeverityScreen(
                currentLocation: _currentLocation,
              ),
            ),
          );
        },
        child: Container(
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
              // Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_taxi_rounded,
                  color: Color(0xFFD32F2F),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),

              // Text
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Ambulance',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Dispatch immediately to current location',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chevron_right_rounded,
                    color: Colors.grey, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Quick Actions ────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionCard(
              icon: Icons.local_hospital_rounded,
              iconBg: const Color(0xFF1565C0),
              title: 'Find Hospital',
              subtitle: 'View nearby ERs',
              onTap: () {},
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.phone_rounded,
              iconBg: const Color(0xFF00BCD4),
              title: 'Call Doctor',
              subtitle: 'Connect to support',
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  // ── Map Section ──────────────────────────────────────────────────────────
  Widget _buildMapSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Icon(Icons.my_location_rounded,
                  color: Color(0xFF1A1A2E), size: 18),
              const SizedBox(width: 6),
              const Text(
                'Current Location',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _highAccuracy
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _highAccuracy
                            ? const Color(0xFF43A047)
                            : const Color(0xFFFFA726),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _locationLoaded
                          ? (_highAccuracy ? 'HIGH ACCURACY' : 'LOW ACCURACY')
                          : 'LOCATING...',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _highAccuracy
                            ? const Color(0xFF43A047)
                            : const Color(0xFFFFA726),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Coordinates subtitle
          if (_locationLoaded) ...[
            const SizedBox(height: 4),
            Text(
              _locationAddress,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Map container
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 240,
              child: Stack(
                children: [
                  // Flutter Map with OpenStreetMap tiles
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation,
                      initialZoom: 16.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom |
                            InteractiveFlag.doubleTapZoom,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.jeevanpath.app',
                        maxZoom: 19,
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLocation,
                            width: 44,
                            height: 44,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow ring
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1565C0)
                                        .withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                // Inner dot
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1565C0),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1565C0)
                                            .withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Loading overlay — shown until real location arrives
                  if (!_locationLoaded)
                    Container(
                      color: Colors.white.withOpacity(0.85),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFF1565C0),
                              strokeWidth: 2.5,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Getting your location...',
                              style: TextStyle(
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Estimated response time card at bottom
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Estimated Response Time',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                _locationLoaded ? '4 mins away' : 'Calculating...',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF1565C0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.directions_car_rounded,
                              color: Color(0xFF1565C0),
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recenter button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        _mapController.move(_currentLocation, 16.0);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.my_location_rounded,
                            color: Color(0xFF1565C0), size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Action Card Widget ─────────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dispatching Dialog Widget ─────────────────────────────────────────────────
class _DispatchingDialog extends StatefulWidget {
  final SosSession session;
  final LatLng currentLocation;
  final VoidCallback onCancel;

  const _DispatchingDialog({
    required this.session,
    required this.currentLocation,
    required this.onCancel,
  });

  @override
  State<_DispatchingDialog> createState() => _DispatchingDialogState();
}

class _DispatchingDialogState extends State<_DispatchingDialog> {
  // Simulated dispatch stages
  int _stage = 0;
  // 0 = searching driver
  // 1 = driver found
  // 2 = en route
  Timer? _stageTimer;

  final List<_DispatchStage> _stages = const [
    _DispatchStage(
      icon: Icons.search_rounded,
      color: Color(0xFFFFA726),
      title: 'Finding nearest ambulance...',
      subtitle: 'Searching drivers in your area',
    ),
    _DispatchStage(
      icon: Icons.local_shipping_rounded,
      color: Color(0xFF1565C0),
      title: 'Driver Assigned!',
      subtitle: 'Ambulance #KA-01-AB-1234 • Ravi Kumar',
    ),
    _DispatchStage(
      icon: Icons.directions_car_rounded,
      color: Color(0xFF43A047),
      title: 'Ambulance En Route',
      subtitle: 'Estimated arrival: 4 minutes',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-advance stages to simulate real dispatch
    _stageTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _stage = 1);
      _stageTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _stage = 2);
      });
    });
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = _stages[_stage];

    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated status icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Container(
                key: ValueKey(_stage),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: stage.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(stage.icon, color: stage.color, size: 36),
              ),
            ),

            const SizedBox(height: 16),

            // SOS ID
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'SOS ID: ${widget.session.sessionId.substring(4, 17)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD32F2F),
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Status title
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                stage.title,
                key: ValueKey('title_$_stage'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),

            const SizedBox(height: 6),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                stage.subtitle,
                key: ValueKey('sub_$_stage'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Progress steps
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _stage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i <= _stage
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // Location being shared info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Color(0xFF43A047), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live location shared with driver',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        Text(
                          '${widget.currentLocation.latitude.toStringAsFixed(5)}, '
                          '${widget.currentLocation.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF43A047),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF43A047),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Done / Cancel buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD32F2F),
                      side: const BorderSide(color: Color(0xFFD32F2F)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Cancel SOS',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43A047),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Track',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DispatchStage {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _DispatchStage({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}
