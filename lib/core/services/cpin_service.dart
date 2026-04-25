import 'dart:math';

/// C-PIN Service
/// Each registered patient has a unique 4-digit C-PIN stored in the database.
/// The C-PIN must be entered before an SOS can be dispatched.
/// This prevents accidental SOS triggers.
///
/// In production: fetch from Supabase/backend using the patient's user ID.
class CPinService {
  CPinService._();
  static final CPinService instance = CPinService._();

  // Simulated database of user C-PINs
  // key = userId, value = 4-digit C-PIN
  final Map<String, String> _pinDatabase = {
    'user_001': '4821',
    'user_002': '7364',
    'user_003': '1592',
  };

  // Active SOS sessions: userId → SOS details
  final Map<String, SosSession> _activeSessions = {};

  /// Fetches the C-PIN for a user from the "database".
  /// Returns null if user not found.
  Future<String?> fetchCPin(String userId) async {
    // Simulate network call
    await Future.delayed(const Duration(milliseconds: 500));
    return _pinDatabase[userId];
  }

  /// Verifies the entered PIN against the stored one.
  Future<CPinResult> verifyPin(String userId, String enteredPin) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final stored = _pinDatabase[userId];
    if (stored == null) return CPinResult.userNotFound;
    if (enteredPin == stored) return CPinResult.success;
    return CPinResult.invalid;
  }

  /// Registers a new user with a randomly generated C-PIN.
  /// Called during patient registration.
  String generateAndStorePin(String userId) {
    final pin = _generatePin();
    _pinDatabase[userId] = pin;
    return pin;
  }

  /// Creates an active SOS session after PIN is verified.
  SosSession createSosSession({
    required String userId,
    required String userName,
    required double latitude,
    required double longitude,
  }) {
    final session = SosSession(
      sessionId: 'SOS_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
      status: SosStatus.dispatching,
    );
    _activeSessions[userId] = session;
    return session;
  }

  /// Updates location in active SOS session (live tracking).
  void updateLocation(String userId, double lat, double lng) {
    final session = _activeSessions[userId];
    if (session != null) {
      _activeSessions[userId] = SosSession(
        sessionId: session.sessionId,
        userId: session.userId,
        userName: session.userName,
        latitude: lat,
        longitude: lng,
        createdAt: session.createdAt,
        status: session.status,
        assignedDriverId: session.assignedDriverId,
        estimatedMinutes: session.estimatedMinutes,
      );
    }
  }

  /// Cancels an active SOS session.
  void cancelSos(String userId) {
    _activeSessions.remove(userId);
  }

  SosSession? getActiveSession(String userId) => _activeSessions[userId];

  String _generatePin() {
    final rand = Random.secure();
    return List.generate(4, (_) => rand.nextInt(10)).join();
  }
}

enum CPinResult { success, invalid, userNotFound }

enum SosStatus { dispatching, driverAssigned, enRoute, arrived, completed }

class SosSession {
  final String sessionId;
  final String userId;
  final String userName;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final SosStatus status;
  final String? assignedDriverId;
  final int? estimatedMinutes;

  const SosSession({
    required this.sessionId,
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.status,
    this.assignedDriverId,
    this.estimatedMinutes,
  });
}
