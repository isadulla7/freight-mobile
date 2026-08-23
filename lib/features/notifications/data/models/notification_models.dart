class NotificationResponse {
  final String notificationId;
  final String type;
  final String sourceType;
  final String? sourceId;
  final Map<String, dynamic>? templateData;
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
      templateData: json['templateData'] as Map<String, dynamic>?,
      readAt: json['readAt'] as String?,
      createdAt: json['createdAt'] as String,
      expiresAt: json['expiresAt'] as String?,
    );
  }

  bool get isRead => readAt != null;

  String get title => switch (type) {
        'OFFER_RECEIVED' => 'Yangi taklif olindi',
        'OFFER_ACCEPTED' => 'Taklifingiz qabul qilindi',
        'OFFER_REJECTED' => 'Taklifingiz rad etildi',
        'SHIPMENT_STATUS_CHANGED' => 'Yetkazish holati o\'zgardi',
        'NEW_MESSAGE' => 'Yangi xabar',
        'LOAD_MATCHED' => 'Yukka mos topildi',
        'DRIVER_ASSIGNED' => 'Haydovchi tayinlandi',
        _ => type,
      };

  String get icon => switch (type) {
        'OFFER_RECEIVED' || 'OFFER_ACCEPTED' || 'OFFER_REJECTED' =>
          'local_offer',
        'SHIPMENT_STATUS_CHANGED' => 'local_shipping',
        'NEW_MESSAGE' => 'chat',
        'LOAD_MATCHED' => 'check_circle',
        'DRIVER_ASSIGNED' => 'person',
        _ => 'notifications',
      };
}
