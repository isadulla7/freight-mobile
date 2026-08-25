import '../../../core/network/api_client.dart';
import 'models/shipment_models.dart';

class ShipmentRepository {
  final ApiClient _api;

  ShipmentRepository(this._api);

  /// Taklif qabul qilingandan keyin chaqiriladi — busiz yetkazish
  /// yozuvi umuman yaratilmaydi va "Yetkazishlar" bo'sh qolaveradi.
  Future<String> createShipment({
    required String offerId,
    required String loadId,
    required String driverProfileId,
    required String vehicleId,
    required int acceptedAmount,
    required String acceptedCurrency,
    String? shipperUserId,
    String? carrierUserId,
  }) async {
    final response = await _api.dio.post('/shipments', data: {
      'offerId': offerId,
      'loadId': loadId,
      'driverProfileId': driverProfileId,
      'vehicleId': vehicleId,
      'acceptedAmount': acceptedAmount,
      'acceptedCurrency': acceptedCurrency,
      'shipperUserId': ?shipperUserId,
      'carrierUserId': ?carrierUserId,
    });
    final data = response.data as Map<String, dynamic>;
    return data['shipmentId'] as String;
  }

  Future<ShipmentResponse> getShipment(String shipmentId) async {
    final response = await _api.dio.get('/shipments/$shipmentId');
    return ShipmentResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<ShipmentResponse>> getMyShipments() async {
    final response = await _api.dio.get('/shipments/my');
    final data = response.data as Map<String, dynamic>;
    return (data['shipments'] as List<dynamic>)
        .map((e) => ShipmentResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateStatus(
    String shipmentId, {
    required String status,
    String? reasonCode,
    String? reasonContext,
  }) async {
    await _api.dio.post('/shipments/$shipmentId/status', data: {
      'status': status,
      'reasonCode': ?reasonCode,
      'reasonContext': ?reasonContext,
    });
  }

  Future<List<StatusHistoryEntry>> getStatusHistory(String shipmentId) async {
    final response = await _api.dio.get('/shipments/$shipmentId/status-history');
    final data = response.data as Map<String, dynamic>;
    return (data['history'] as List<dynamic>)
        .map((e) => StatusHistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
