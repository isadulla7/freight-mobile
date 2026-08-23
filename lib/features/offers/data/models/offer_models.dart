class OfferResponse {
  final String offerId;
  final String loadId;
  final String? offererUserId;
  final String? offererCompanyId;
  final String driverProfileId;
  final String vehicleId;
  final int amount;
  final String? currency;
  final String? message;
  final String status;
  final int version;
  final String createdAt;
  final String updatedAt;

  const OfferResponse({
    required this.offerId,
    required this.loadId,
    this.offererUserId,
    this.offererCompanyId,
    required this.driverProfileId,
    required this.vehicleId,
    required this.amount,
    this.currency,
    this.message,
    required this.status,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OfferResponse.fromJson(Map<String, dynamic> json) {
    return OfferResponse(
      offerId: json['offerId'] as String,
      loadId: json['loadId'] as String,
      offererUserId: json['offererUserId'] as String?,
      offererCompanyId: json['offererCompanyId'] as String?,
      driverProfileId: json['driverProfileId'] as String,
      vehicleId: json['vehicleId'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String?,
      message: json['message'] as String?,
      status: json['status'] as String,
      version: json['version'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  String get formattedAmount {
    final formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
    return '$formatted ${currency ?? 'UZS'}';
  }

  String get statusLabel => switch (status) {
        'PENDING' => 'Kutilmoqda',
        'ACCEPTED' => 'Qabul qilindi',
        'REJECTED' => 'Rad etildi',
        'WITHDRAWN' => 'Qaytarildi',
        'EXPIRED' => 'Muddati tugadi',
        _ => status,
      };
}

class CreateOfferPayload {
  final String loadId;
  final String? offererCompanyId;
  final String driverProfileId;
  final String vehicleId;
  final int amount;
  final String? currency;
  final String? message;

  const CreateOfferPayload({
    required this.loadId,
    this.offererCompanyId,
    required this.driverProfileId,
    required this.vehicleId,
    required this.amount,
    this.currency,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'loadId': loadId,
      if (offererCompanyId != null) 'offererCompanyId': offererCompanyId,
      'driverProfileId': driverProfileId,
      'vehicleId': vehicleId,
      'amount': amount,
      if (currency != null) 'currency': currency,
      if (message != null) 'message': message,
    };
  }
}
