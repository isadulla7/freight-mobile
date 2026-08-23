class ShipmentResponse {
  final String shipmentId;
  final String offerId;
  final String loadId;
  final String? shipperUserId;
  final String? shipperCompanyId;
  final String? carrierUserId;
  final String? carrierCompanyId;
  final String driverProfileId;
  final String vehicleId;
  final int acceptedAmount;
  final String acceptedCurrency;
  final String status;
  final int version;
  final String createdAt;
  final String updatedAt;

  const ShipmentResponse({
    required this.shipmentId,
    required this.offerId,
    required this.loadId,
    this.shipperUserId,
    this.shipperCompanyId,
    this.carrierUserId,
    this.carrierCompanyId,
    required this.driverProfileId,
    required this.vehicleId,
    required this.acceptedAmount,
    required this.acceptedCurrency,
    required this.status,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShipmentResponse.fromJson(Map<String, dynamic> json) {
    return ShipmentResponse(
      shipmentId: json['shipmentId'] as String,
      offerId: json['offerId'] as String,
      loadId: json['loadId'] as String,
      shipperUserId: json['shipperUserId'] as String?,
      shipperCompanyId: json['shipperCompanyId'] as String?,
      carrierUserId: json['carrierUserId'] as String?,
      carrierCompanyId: json['carrierCompanyId'] as String?,
      driverProfileId: json['driverProfileId'] as String,
      vehicleId: json['vehicleId'] as String,
      acceptedAmount: json['acceptedAmount'] as int,
      acceptedCurrency: json['acceptedCurrency'] as String,
      status: json['status'] as String,
      version: json['version'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  String get formattedAmount {
    final formatted = acceptedAmount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
    return '$formatted $acceptedCurrency';
  }

  String get statusLabel => switch (status) {
        'CREATED' => 'Yaratildi',
        'DRIVER_ASSIGNED' => 'Haydovchi tayinlandi',
        'HEADING_TO_PICKUP' => 'Yuklash joyiga ketmoqda',
        'AT_PICKUP' => 'Yuklash joyida',
        'LOADED' => 'Yuklandi',
        'IN_TRANSIT' => "Yo'lda",
        'DELIVERED' => 'Yetkazildi',
        'COMPLETED' => 'Yakunlandi',
        'CANCELLED' => 'Bekor qilindi',
        _ => status,
      };
}

class StatusHistoryEntry {
  final String id;
  final String shipmentId;
  final String? previousStatus;
  final String newStatus;
  final String? actorUserId;
  final String? reasonCode;
  final String? reasonContext;
  final String changedAt;

  const StatusHistoryEntry({
    required this.id,
    required this.shipmentId,
    this.previousStatus,
    required this.newStatus,
    this.actorUserId,
    this.reasonCode,
    this.reasonContext,
    required this.changedAt,
  });

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) {
    return StatusHistoryEntry(
      id: json['id'] as String,
      shipmentId: json['shipmentId'] as String,
      previousStatus: json['previousStatus'] as String?,
      newStatus: json['newStatus'] as String,
      actorUserId: json['actorUserId'] as String?,
      reasonCode: json['reasonCode'] as String?,
      reasonContext: json['reasonContext'] as String?,
      changedAt: json['changedAt'] as String,
    );
  }
}
