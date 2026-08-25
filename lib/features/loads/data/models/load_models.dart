class LoadStopPayload {
  final int sequence;
  final String stopType;
  final String? address;
  final String? contactName;
  final String? contactPhone;
  final String? countryCode;
  final String? city;
  final String? region;

  /// Koordinatasiz yuk qidiruvda umuman ko'rinmaydi — backend
  /// masofa bo'yicha (ST_DWithin) filtrlaydi.
  final double? latitude;
  final double? longitude;

  const LoadStopPayload({
    required this.sequence,
    required this.stopType,
    this.address,
    this.contactName,
    this.contactPhone,
    this.countryCode,
    this.city,
    this.region,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'sequence': sequence,
      'stopType': stopType,
      'address': ?address,
      'contactName': ?contactName,
      'contactPhone': ?contactPhone,
      'countryCode': ?countryCode,
      'city': ?city,
      'region': ?region,
      'latitude': ?latitude,
      'longitude': ?longitude,
    };
  }
}

class LoadStop {
  final int sequence;
  final String stopType;
  final String? address;
  final String? contactName;
  final String? contactPhone;
  final String? countryCode;
  final String? city;
  final String? region;

  const LoadStop({
    required this.sequence,
    required this.stopType,
    this.address,
    this.contactName,
    this.contactPhone,
    this.countryCode,
    this.city,
    this.region,
  });

  factory LoadStop.fromJson(Map<String, dynamic> json) {
    return LoadStop(
      sequence: json['sequence'] as int,
      stopType: json['stopType'] as String,
      address: json['address'] as String?,
      contactName: json['contactName'] as String?,
      contactPhone: json['contactPhone'] as String?,
      countryCode: json['countryCode'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
    );
  }
}

class LoadResponse {
  final String loadId;
  final String? ownerUserId;
  final String? ownerCompanyId;
  final String status;
  final String? cargoType;
  final String? cargoDescription;
  final int? cargoWeightKg;
  final int? cargoVolumeM3;
  final String? pricingMode;
  final int? priceAmount;
  final String? priceCurrency;
  final String? routeType;
  final String? acceptedOfferId;
  final int version;
  final List<LoadStop> stops;

  const LoadResponse({
    required this.loadId,
    this.ownerUserId,
    this.ownerCompanyId,
    required this.status,
    this.cargoType,
    this.cargoDescription,
    this.cargoWeightKg,
    this.cargoVolumeM3,
    this.pricingMode,
    this.priceAmount,
    this.priceCurrency,
    this.routeType,
    this.acceptedOfferId,
    required this.version,
    required this.stops,
  });

  factory LoadResponse.fromJson(Map<String, dynamic> json) {
    return LoadResponse(
      loadId: json['loadId'] as String,
      ownerUserId: json['ownerUserId'] as String?,
      ownerCompanyId: json['ownerCompanyId'] as String?,
      status: json['status'] as String,
      cargoType: json['cargoType'] as String?,
      cargoDescription: json['cargoDescription'] as String?,
      cargoWeightKg: json['cargoWeightKg'] as int?,
      cargoVolumeM3: json['cargoVolumeM3'] as int?,
      pricingMode: json['pricingMode'] as String?,
      priceAmount: json['priceAmount'] as int?,
      priceCurrency: json['priceCurrency'] as String?,
      routeType: json['routeType'] as String?,
      acceptedOfferId: json['acceptedOfferId'] as String?,
      version: json['version'] as int,
      stops: (json['stops'] as List<dynamic>?)
              ?.map((e) => LoadStop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get pickupCity {
    final pickup = stops.where((s) => s.stopType == 'PICKUP').firstOrNull;
    return pickup?.city ?? pickup?.address ?? '';
  }

  String get deliveryCity {
    final delivery = stops.where((s) => s.stopType == 'DELIVERY').firstOrNull;
    return delivery?.city ?? delivery?.address ?? '';
  }

  String get formattedWeight {
    if (cargoWeightKg == null) return '';
    if (cargoWeightKg! >= 1000) {
      return '${(cargoWeightKg! / 1000).toStringAsFixed(cargoWeightKg! % 1000 == 0 ? 0 : 1)} t';
    }
    return '$cargoWeightKg kg';
  }

  String get formattedPrice {
    if (priceAmount == null) return 'Taklif kutilmoqda';
    final formatted = priceAmount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
    return '$formatted ${priceCurrency ?? 'UZS'}';
  }

  String get formattedVolume {
    if (cargoVolumeM3 == null) return '';
    return '$cargoVolumeM3 m³';
  }
}

class CreateLoadPayload {
  final String? ownerCompanyId;
  final String? cargoType;
  final String? cargoDescription;
  final int? cargoWeightKg;
  final int? cargoVolumeM3;
  final int? cargoQuantity;
  final String? pricingMode;
  final int? priceAmount;
  final String? priceCurrency;
  final List<LoadStopPayload>? stops;

  const CreateLoadPayload({
    this.ownerCompanyId,
    this.cargoType,
    this.cargoDescription,
    this.cargoWeightKg,
    this.cargoVolumeM3,
    this.cargoQuantity,
    this.pricingMode,
    this.priceAmount,
    this.priceCurrency,
    this.stops,
  });

  Map<String, dynamic> toJson() {
    return {
      if (ownerCompanyId != null) 'ownerCompanyId': ownerCompanyId,
      if (cargoType != null) 'cargoType': cargoType,
      if (cargoDescription != null) 'cargoDescription': cargoDescription,
      if (cargoWeightKg != null) 'cargoWeightKg': cargoWeightKg,
      if (cargoVolumeM3 != null) 'cargoVolumeM3': cargoVolumeM3,
      if (cargoQuantity != null) 'cargoQuantity': cargoQuantity,
      if (pricingMode != null) 'pricingMode': pricingMode,
      if (priceAmount != null) 'priceAmount': priceAmount,
      if (priceCurrency != null) 'priceCurrency': priceCurrency,
      if (stops != null) 'stops': stops!.map((s) => s.toJson()).toList(),
    };
  }
}
