class SessionTokens {
  final String sessionId;
  final String accessToken;
  final String refreshToken;
  final String expiresAt;

  const SessionTokens({
    required this.sessionId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory SessionTokens.fromJson(Map<String, dynamic> json) {
    return SessionTokens(
      sessionId: json['sessionId'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: json['expiresAt'] as String,
    );
  }
}

class DeviceSession {
  final String sessionId;
  final String deviceId;
  final String status;
  final String issuedAt;
  final String expiresAt;
  final String? revokedAt;
  final bool current;

  const DeviceSession({
    required this.sessionId,
    required this.deviceId,
    required this.status,
    required this.issuedAt,
    required this.expiresAt,
    this.revokedAt,
    required this.current,
  });

  factory DeviceSession.fromJson(Map<String, dynamic> json) {
    return DeviceSession(
      sessionId: json['sessionId'] as String,
      deviceId: json['deviceId'] as String,
      status: json['status'] as String,
      issuedAt: json['issuedAt'] as String,
      expiresAt: json['expiresAt'] as String,
      revokedAt: json['revokedAt'] as String?,
      current: json['current'] as bool,
    );
  }
}
