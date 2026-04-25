import 'dart:math';

/// Simulates OTP generation and verification.
/// In production, replace _sendSmsOtp() with your SMS gateway
/// (e.g. Twilio, MSG91, Fast2SMS, AWS SNS).
class OtpService {
  OtpService._();
  static final OtpService instance = OtpService._();

  // Stores generated OTPs keyed by phone number
  final Map<String, _OtpEntry> _store = {};

  static const int _otpLength = 4;
  static const int _expirySeconds = 120; // 2 minutes

  /// Generates a 4-digit OTP, stores it, and "sends" it.
  /// Returns the OTP string (for dev/demo — remove in production).
  /// FIXED TO ALWAYS BE "1234" FOR EASY TESTING
  String generateAndSend(String phone) {
    const otp = '1234'; // FIXED OTP FOR TESTING
    _store[phone] = _OtpEntry(
      otp: otp,
      expiresAt: DateTime.now().add(
        const Duration(seconds: _expirySeconds),
      ),
      attempts: 0,
    );

    // In production: call SMS API here
    // await SmsGateway.send(phone, 'Your JeevanPath OTP is $otp');

    debugLog('📱 OTP for $phone → $otp (expires in ${_expirySeconds}s)');
    return otp;
  }

  /// Verifies the OTP entered by the user.
  OtpResult verify(String phone, String enteredOtp) {
    final entry = _store[phone];

    if (entry == null) {
      return OtpResult.notFound;
    }

    if (DateTime.now().isAfter(entry.expiresAt)) {
      _store.remove(phone);
      return OtpResult.expired;
    }

    if (entry.attempts >= 3) {
      _store.remove(phone);
      return OtpResult.tooManyAttempts;
    }

    if (enteredOtp.trim() == entry.otp) {
      _store.remove(phone); // OTP used — remove it
      return OtpResult.success;
    }

    // Wrong OTP — increment attempts
    _store[phone] = _OtpEntry(
      otp: entry.otp,
      expiresAt: entry.expiresAt,
      attempts: entry.attempts + 1,
    );
    return OtpResult.invalid;
  }

  /// Clears OTP for a phone (e.g. on resend)
  void clear(String phone) => _store.remove(phone);

  String _generateOtp() {
    final rand = Random.secure();
    return List.generate(_otpLength, (_) => rand.nextInt(10)).join();
  }

  void debugLog(String msg) {
    // ignore: avoid_print
    print(msg);
  }
}

class _OtpEntry {
  final String otp;
  final DateTime expiresAt;
  final int attempts;

  const _OtpEntry({
    required this.otp,
    required this.expiresAt,
    required this.attempts,
  });
}

enum OtpResult {
  success,
  invalid,
  expired,
  notFound,
  tooManyAttempts,
}
