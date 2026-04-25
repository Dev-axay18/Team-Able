import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/otp_service.dart';
import '../home/main_navigation.dart';
import '../driver/driver_dashboard.dart';
import 'role_selection_screen.dart';

// ── Country model ────────────────────────────────────────────────────────────
class _Country {
  final String flag;
  final String name;
  final String code;
  final int maxDigits;

  const _Country({
    required this.flag,
    required this.name,
    required this.code,
    required this.maxDigits,
  });
}

const List<_Country> _countries = [
  _Country(flag: '🇮🇳', name: 'India',          code: '+91', maxDigits: 10),
  _Country(flag: '🇺🇸', name: 'United States',   code: '+1',  maxDigits: 10),
  _Country(flag: '🇬🇧', name: 'United Kingdom',  code: '+44', maxDigits: 10),
  _Country(flag: '🇦🇪', name: 'UAE',             code: '+971',maxDigits: 9),
  _Country(flag: '🇸🇬', name: 'Singapore',       code: '+65', maxDigits: 8),
];

// ── Login Screen ─────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _Country _selectedCountry = _countries[0]; // India default

  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(4, (_) => FocusNode());

  bool _otpSent = false;
  bool _isLoading = false;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  // Holds the generated OTP for dev banner display
  String? _devOtpHint;
  
  // Role selection
  String _selectedRole = 'Patient';

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  String get _fullPhone =>
      '${_selectedCountry.code}${_phoneController.text.trim()}';

  // ── Send OTP ──────────────────────────────────────────────────────────────
  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < _selectedCountry.maxDigits) {
      _showSnack(
        'Enter a valid ${_selectedCountry.maxDigits}-digit number',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate OTP via service
    final otp = OtpService.instance.generateAndSend(_fullPhone);

    setState(() {
      _isLoading = false;
      _otpSent = true;
      _devOtpHint = otp; // show in dev banner — remove in production
    });

    _startResendTimer();

    _showSnack('OTP sent to $_fullPhone ✓');

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _otpFocusNodes[0].requestFocus();
    });
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────
  Future<void> _verifyIdentity() async {
    if (!_otpSent) {
      await _sendOtp();
      return;
    }

    final entered = _otpControllers.map((c) => c.text).join();
    if (entered.length < 4) {
      _showSnack('Enter the complete 4-digit OTP', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final result = OtpService.instance.verify(_fullPhone, entered);

    switch (result) {
      case OtpResult.success:
        final auth = context.read<AuthProvider>();
        final success = await auth.login(_fullPhone, 'otp_verified');
        if (success && mounted) {
          // Navigate based on selected role
          if (_selectedRole == 'Driver') {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const DriverDashboard()),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainNavigation()),
              (route) => false,
            );
          }
        }
        break;

      case OtpResult.invalid:
        setState(() {
          _isLoading = false;
          for (final c in _otpControllers) c.clear();
        });
        _otpFocusNodes[0].requestFocus();
        _showSnack('Incorrect OTP. Please try again.', isError: true);
        break;

      case OtpResult.expired:
        setState(() {
          _isLoading = false;
          _otpSent = false;
          _devOtpHint = null;
          for (final c in _otpControllers) c.clear();
        });
        _showSnack('OTP expired. Please request a new one.', isError: true);
        break;

      case OtpResult.tooManyAttempts:
        setState(() {
          _isLoading = false;
          _otpSent = false;
          _devOtpHint = null;
          for (final c in _otpControllers) c.clear();
        });
        _showSnack('Too many wrong attempts. Request a new OTP.', isError: true);
        break;

      case OtpResult.notFound:
        setState(() {
          _isLoading = false;
          _otpSent = false;
        });
        _showSnack('Session expired. Please send OTP again.', isError: true);
        break;
    }
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  void _resendOtp() {
    OtpService.instance.clear(_fullPhone);
    for (final c in _otpControllers) c.clear();
    setState(() {
      _otpSent = false;
      _devOtpHint = null;
    });
    _sendOtp();
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? const Color(0xFFD32F2F)
            : const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Country Picker Bottom Sheet ───────────────────────────────────────────
  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Country',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 16),
              ..._countries.map((country) {
                final isSelected = country.code == _selectedCountry.code;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCountry = country;
                      _phoneController.clear();
                      _otpSent = false;
                      _devOtpHint = null;
                      for (final c in _otpControllers) c.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1565C0).withOpacity(0.08)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1565C0)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(country.flag,
                            style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            country.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        Text(
                          country.code,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? const Color(0xFF1565C0)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF1565C0), size: 18),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),

              // ── App Title ─────────────────────────────────────────────
              const Text(
                'JeevanPath AI',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1565C0),
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 40),

              // ── White Card ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Secure Access',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Enter your mobile number and the\nverification code sent to your device.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Role Selection ────────────────────────────────
                      const Text(
                        'Login As',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRole,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF6B7280)),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                            items: ['Patient', 'Driver'].map((String role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Row(
                                  children: [
                                    Icon(
                                      role == 'Patient'
                                          ? Icons.person_outline
                                          : Icons.local_shipping_outlined,
                                      color: const Color(0xFF1565C0),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(role),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedRole = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Mobile Number ────────────────────────────────
                      const Text(
                        'Mobile Number',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // ── Country Code Dropdown ──────────────────
                            GestureDetector(
                              onTap: _showCountryPicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedCountry.flag,
                                      style:
                                          const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _selectedCountry.code,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Color(0xFF1A1A2E),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Divider
                            Container(
                              width: 1,
                              height: 24,
                              color: const Color(0xFFD1D5DB),
                            ),
                            // Phone input
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: _selectedCountry.maxDigits,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF1A1A2E),
                                  letterSpacing: 1.5,
                                ),
                                decoration: InputDecoration(
                                  hintText: '0' *
                                      _selectedCountry.maxDigits,
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    letterSpacing: 1,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 14),
                                  counterText: '',
                                ),
                                onChanged: (val) {
                                  if (val.length ==
                                          _selectedCountry.maxDigits &&
                                      !_otpSent) {
                                    _sendOtp();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── OTP Label + Resend ───────────────────────────
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'One-Time Password',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          GestureDetector(
                            onTap: (_resendSeconds == 0 && _otpSent)
                                ? _resendOtp
                                : null,
                            child: Text(
                              _resendSeconds > 0
                                  ? 'Resend in ${_resendSeconds}s'
                                  : 'Resend Code',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: (_resendSeconds == 0 && _otpSent)
                                    ? const Color(0xFF1565C0)
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── 4 OTP Boxes ──────────────────────────────────
                      Row(
                        children: List.generate(4, (i) {
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                  right: i < 3 ? 12 : 0),
                              height: 58,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                  color: _otpFocusNodes[i].hasFocus
                                      ? const Color(0xFF1565C0)
                                      : _otpControllers[i]
                                              .text
                                              .isNotEmpty
                                          ? const Color(0xFF43A047)
                                          : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: TextField(
                                controller: _otpControllers[i],
                                focusNode: _otpFocusNodes[i],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                enabled: _otpSent,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly,
                                ],
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A2E),
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                                onChanged: (val) {
                                  setState(() {});
                                  if (val.isNotEmpty && i < 3) {
                                    _otpFocusNodes[i + 1]
                                        .requestFocus();
                                  }
                                  if (val.isEmpty && i > 0) {
                                    _otpFocusNodes[i - 1]
                                        .requestFocus();
                                  }
                                  // Auto verify when all 4 filled
                                  final full = _otpControllers
                                      .map((c) => c.text)
                                      .join();
                                  if (full.length == 4) {
                                    _verifyIdentity();
                                  }
                                },
                              ),
                            ),
                          );
                        }),
                      ),

                      // ── Dev OTP Banner ───────────────────────────────
                      if (_devOtpHint != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFFFFD54F)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.developer_mode_rounded,
                                  color: Color(0xFFF57C00), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Dev mode — OTP: $_devOtpHint',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFF57C00),
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // ── Verify Button ────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _verifyIdentity,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            disabledBackgroundColor:
                                const Color(0xFF1565C0).withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _otpSent
                                          ? 'Verify Identity'
                                          : 'Send OTP',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _otpSent
                                          ? Icons.verified_user_rounded
                                          : Icons.send_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Help Text ─────────────────────────────────────────────
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  const Text(
                    'Need help accessing your account? ',
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Contact Support',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Sign Up ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RoleSelectionScreen(),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
