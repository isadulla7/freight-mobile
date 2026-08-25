import '../../../core/network/api_client.dart';
import 'models/shipment_models.dart';

class ShipmentRepository {
  final ApiClient _api;

  ShipmentRepository(this._api);

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
