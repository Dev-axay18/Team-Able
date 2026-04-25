/// C-PIN Service
/// Each registered patient has a unique 4-digit C-PIN stored in the database.
/// The C-PIN must be entered before an SOS can be dispatched.
/// This prevents accidental SOS triggers.
///
/// In production: fetch from Supabase/backend using the patient's user ID.
class CPinService {
  CPinService._();
  static final CPinService instance = CPinService._();

  // Default CPIN for all users (dummy/mock)
  static const String _defaultPin = '1234';

  // Simulated database of user C-PINs
  // key = userId, value = 4-digit C-PIN
  // All users default to '1234' unless they set a custom one
  final Map<String, String> _pinDatabase = {
    'user_001': '1234',
    'user_002': '1234',
    'user_003': '1234',
  };

  // Active SOS sessions: userId → SOS details
  final Map<String, SosSession> _activeSessions = {};

  /// Fetches the C-PIN for a user from the "database".
  /// Returns '1234' as default if user not found.
  Future<String?> fetchCPin(String userId) async {
    // Simulate network call
    await Future.delayed(const Duration(milliseconds: 500));
    // Return stored pin or default '1234'
    return _pinDatabase[userId] ?? _defaultPin;
  }

  /// Verifies the entered PIN against the stored one.
  /// Always accepts '1234' as a valid fallback for any user.
  Future<CPinResult> verifyPin(String userId, String enteredPin) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Get stored pin, fallback to default '1234'
    final stored = _pinDatabase[userId] ?? _defaultPin;
    
    if (enteredPin.trim() == stored) return CPinResult.success;
    // Also always accept '1234' as universal fallback
    if (enteredPin.trim() == _defaultPin) return CPinResult.success;
    
    return CPinResult.invalid;
  }

  /// Registers a new user with default C-PIN '1234'.
  /// Called during patient registration.
  String generateAndStorePin(String userId) {
    // Store '1234' as default for new users
    _pinDatabase[userId] = _defaultPin;
    return _defaultPin;
  }

  /// Updates the C-PIN for a user.
  void updatePin(String userId, String newPin) {
    _pinDatabase[userId] = newPin;
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
