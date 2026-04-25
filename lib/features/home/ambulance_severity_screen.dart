import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/cpin_service.dart';
import 'package:latlong2/latlong.dart';

class AmbulanceSeverityScreen extends StatefulWidget {
  final LatLng currentLocation;

  const AmbulanceSeverityScreen({
    super.key,
    required this.currentLocation,
  });

  @override
  State<AmbulanceSeverityScreen> createState() =>
      _AmbulanceSeverityScreenState();
}

class _AmbulanceSeverityScreenState extends State<AmbulanceSeverityScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedSeverity;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<SeverityLevel> _severityLevels = const [
    SeverityLevel(
      id: 'critical',
      title: 'Critical',
      description: 'Life-threatening emergency',
      examples: 'Heart attack, severe bleeding, unconscious',
      color: Color(0xFFB71C1C),
      icon: Icons.emergency_rounded,
      priority: 1,
    ),
    SeverityLevel(
      id: 'severe',
      title: 'Severe',
      description: 'Serious medical condition',
      examples: 'Severe pain, difficulty breathing, major injury',
      color: Color(0xFFD32F2F),
      icon: Icons.local_hospital_rounded,
      priority: 2,
    ),
    SeverityLevel(
      id: 'moderate',
      title: 'Moderate',
      description: 'Urgent but stable',
      examples: 'Moderate pain, minor fracture, high fever',
      color: Color(0xFFFFA726),
      icon: Icons.medical_services_rounded,
      priority: 3,
    ),
    SeverityLevel(
      id: 'minor',
      title: 'Minor',
      description: 'Non-urgent medical need',
      examples: 'Minor cuts, sprains, routine transport',
      color: Color(0xFF43A047),
      icon: Icons.healing_rounded,
      priority: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onSeveritySelected(SeverityLevel level) {
    setState(() => _selectedSeverity = level.id);
    HapticFeedback.mediumImpact();
  }

  Future<void> _confirmAndDispatch() async {
    if (_selectedSeverity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a severity level'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selectedLevel = _severityLevels.firstWhere(
      (level) => level.id == _selectedSeverity,
    );

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmationDialog(level: selectedLevel),
    );

    if (confirmed == true && mounted) {
      _showCPinDialog(selectedLevel);
    }
  }

  void _showCPinDialog(SeverityLevel level) {
    HapticFeedback.mediumImpact();
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final List<TextEditingController> pinControllers =
        List.generate(4, (_) => TextEditingController());
    final List<FocusNode> pinFocusNodes = List.generate(4, (_) => FocusNode());
    bool isVerifying = false;
    String? errorMsg;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            Future<void> verifyPin() async {
              final entered = pinControllers.map((c) => c.text).join();
              if (entered.length < 4) return;

              setDialogState(() {
                isVerifying = true;
                errorMsg = null;
              });

              final result =
                  await CPinService.instance.verifyPin(user.id, entered);

              if (!ctx.mounted) return;

              switch (result) {
                case CPinResult.success:
                  Navigator.of(ctx).pop();
                  _dispatchAmbulance(user, level);
                  break;

                case CPinResult.invalid:
                  HapticFeedback.vibrate();
                  for (final c in pinControllers) {
                    c.clear();
                  }
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
                      backgroundColor: AppTheme.errorColor,
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
                    // Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: level.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shield_rounded,
                        color: level.color,
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
                    Text(
                      'Verify your identity to dispatch\n${level.title} priority ambulance',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                                  ? level.color
                                  : pinFocusNodes[i].hasFocus
                                      ? level.color
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
                              final full =
                                  pinControllers.map((c) => c.text).join();
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
                          Icon(Icons.error_outline_rounded,
                              color: level.color, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            errorMsg!,
                            style: TextStyle(
                              color: level.color,
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
                          backgroundColor: level.color,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: isVerifying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white),
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
                      onPressed: () => Navigator.of(ctx).pop(),
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

  void _dispatchAmbulance(dynamic user, SeverityLevel level) {
    HapticFeedback.heavyImpact();

    final session = CPinService.instance.createSosSession(
      userId: user.id,
      userName: user.name,
      latitude: widget.currentLocation.latitude,
      longitude: widget.currentLocation.longitude,
    );

    // Show success and navigate back
    Navigator.of(context).pop(); // Close severity screen

    // Show dispatching dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DispatchSuccessDialog(
        level: level,
        session: session,
        currentLocation: widget.currentLocation,
      ),
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
          'Select Emergency Level',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
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
                        'Select the severity level to help us prioritize and dispatch the appropriate ambulance',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Severity cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: _severityLevels.length,
                  itemBuilder: (context, index) {
                    final level = _severityLevels[index];
                    final isSelected = _selectedSeverity == level.id;

                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _SeverityCard(
                          level: level,
                          isSelected: isSelected,
                          onTap: () => _onSeveritySelected(level),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Confirm button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedSeverity != null
                          ? _confirmAndDispatch
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedSeverity != null
                            ? _severityLevels
                                .firstWhere((l) => l.id == _selectedSeverity)
                                .color
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirm & Request Ambulance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeverityCard extends StatelessWidget {
  final SeverityLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeverityCard({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? level.color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? level.color.withOpacity(0.2)
                  : Colors.black.withOpacity(0.06),
              blurRadius: isSelected ? 16 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: level.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(level.icon, color: level.color, size: 28),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        level.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: level.color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: level.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'P${level.priority}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: level.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    level.examples,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? level.color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? level.color : const Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmationDialog extends StatelessWidget {
  final SeverityLevel level;

  const _ConfirmationDialog({required this.level});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(level.icon, color: level.color, size: 28),
          const SizedBox(width: 12),
          Text(
            'Confirm ${level.title}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are requesting a ${level.title.toLowerCase()} priority ambulance.',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: level.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: level.color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Emergency services will be dispatched immediately',
                    style: TextStyle(
                      fontSize: 12,
                      color: level.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: level.color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

class _DispatchSuccessDialog extends StatefulWidget {
  final SeverityLevel level;
  final SosSession session;
  final LatLng currentLocation;

  const _DispatchSuccessDialog({
    required this.level,
    required this.session,
    required this.currentLocation,
  });

  @override
  State<_DispatchSuccessDialog> createState() => _DispatchSuccessDialogState();
}

class _DispatchSuccessDialogState extends State<_DispatchSuccessDialog> {
  int _stage = 0;
  Timer? _stageTimer;

  @override
  void initState() {
    super.initState();
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
    final stages = [
      'Finding nearest ambulance...',
      'Ambulance assigned!',
      'En route to your location',
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: widget.level.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.level.icon,
                  color: widget.level.color, size: 36),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: widget.level.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${widget.level.title.toUpperCase()} PRIORITY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: widget.level.color,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              stages[_stage],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 20),
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
                        ? widget.level.color
                        : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.level.color,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Track Ambulance',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SeverityLevel {
  final String id;
  final String title;
  final String description;
  final String examples;
  final Color color;
  final IconData icon;
  final int priority;

  const SeverityLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.examples,
    required this.color,
    required this.icon,
    required this.priority,
  });
}
