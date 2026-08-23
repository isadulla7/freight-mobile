class UserResponse {
  final String userId;
  final String displayName;
  final String status;
  final String? locale;

  const UserResponse({
    required this.userId,
    required this.displayName,
    required this.status,
    this.locale,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      status: json['status'] as String,
      locale: json['locale'] as String?,
    );
  }

  String get initials {
    final parts = displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }
}

class DriverEligibilityResponse {
  final bool eligible;
  final bool hasDriverProfile;
  final String? verificationStatus;

  const DriverEligibilityResponse({
    required this.eligible,
    required this.hasDriverProfile,
    this.verificationStatus,
  });

  factory DriverEligibilityResponse.fromJson(Map<String, dynamic> json) {
    return DriverEligibilityResponse(
      eligible: json['eligible'] as bool,
      hasDriverProfile: json['hasDriverProfile'] as bool,
      verificationStatus: json['verificationStatus'] as String?,
    );
  }
}
