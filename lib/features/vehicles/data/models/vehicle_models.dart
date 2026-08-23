class VehicleResponse {
  final String vehicleId;
  final String? ownerUserId;
  final String? managerCompanyId;
  final String vehicleTypeId;
  final String? bodyTypeId;
  final String plateNumber;
  final int? capacityKg;
  final int? volumeM3;
  final String status;

  const VehicleResponse({
    required this.vehicleId,
    this.ownerUserId,
    this.managerCompanyId,
    required this.vehicleTypeId,
    this.bodyTypeId,
    required this.plateNumber,
    this.capacityKg,
    this.volumeM3,
    required this.status,
  });

  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    return VehicleResponse(
      vehicleId: json['vehicleId'] as String,
      ownerUserId: json['ownerUserId'] as String?,
      managerCompanyId: json['managerCompanyId'] as String?,
      vehicleTypeId: json['vehicleTypeId'] as String,
      bodyTypeId: json['bodyTypeId'] as String?,
      plateNumber: json['plateNumber'] as String,
      capacityKg: json['capacityKg'] as int?,
      volumeM3: json['volumeM3'] as int?,
      status: json['status'] as String,
    );
  }

  String get formattedCapacity {
    if (capacityKg == null) return '';
    if (capacityKg! >= 1000) {
      return '${(capacityKg! / 1000).toStringAsFixed(capacityKg! % 1000 == 0 ? 0 : 1)} t';
    }
    return '$capacityKg kg';
  }
}

class CreateVehiclePayload {
  final String vehicleTypeId;
  final String? bodyTypeId;
  final String plateNumber;
  final String? managerCompanyId;
  final int? capacityKg;
  final int? volumeM3;
  final int? manufactureYear;

  const CreateVehiclePayload({
    required this.vehicleTypeId,
    this.bodyTypeId,
    required this.plateNumber,
    this.managerCompanyId,
    this.capacityKg,
    this.volumeM3,
    this.manufactureYear,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleTypeId': vehicleTypeId,
      if (bodyTypeId != null) 'bodyTypeId': bodyTypeId,
      'plateNumber': plateNumber,
      if (managerCompanyId != null) 'managerCompanyId': managerCompanyId,
      if (capacityKg != null) 'capacityKg': capacityKg,
      if (volumeM3 != null) 'volumeM3': volumeM3,
      if (manufactureYear != null) 'manufactureYear': manufactureYear,
      'capabilityIds': <String>[],
    };
  }
}

class ReferenceEntry {
  final String id;
  final String code;
  final String? label;

  const ReferenceEntry({
    required this.id,
    required this.code,
    this.label,
  });

  factory ReferenceEntry.fromJson(Map<String, dynamic> json) {
    return ReferenceEntry(
      id: json['id'] as String,
      code: json['code'] as String,
      label: json['label'] as String?,
    );
  }

  String get displayName => label ?? code;
}

class NotificationResponse {
  final String notificationId;
  final String type;
  final String sourceType;
  final String? sourceId;
  final String? templateData;
  final String? readAt;
  final String createdAt;
  final String? expiresAt;

  const NotificationResponse({
    required this.notificationId,
    required this.type,
    required this.sourceType,
    this.sourceId,
    this.templateData,
    this.readAt,
    required this.createdAt,
    this.expiresAt,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      notificationId: json['notificationId'] as String,
      type: json['type'] as String,
      sourceType: json['sourceType'] as String,
      sourceId: json['sourceId'] as String?,
      templateData: json['templateData'] as String?,
      readAt: json['readAt'] as String?,
      createdAt: json['createdAt'] as String,
      expiresAt: json['expiresAt'] as String?,
    );
  }

  bool get isRead => readAt != null;
}
