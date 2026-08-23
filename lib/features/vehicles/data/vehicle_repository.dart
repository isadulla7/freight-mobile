import '../../../core/network/api_client.dart';
import 'models/vehicle_models.dart';

class VehicleRepository {
  final ApiClient _api;

  VehicleRepository(this._api);

  Future<String> createVehicle(CreateVehiclePayload payload) async {
    final response = await _api.dio.post('/vehicles', data: payload.toJson());
    final data = response.data as Map<String, dynamic>;
    return data['vehicleId'] as String;
  }

  Future<VehicleResponse> getVehicle(String vehicleId) async {
    final response = await _api.dio.get('/vehicles/$vehicleId');
    return VehicleResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> updateVehicle(
    String vehicleId, {
    String? plateNumber,
    int? capacityKg,
    int? volumeM3,
    int? manufactureYear,
  }) async {
    await _api.dio.patch('/vehicles/$vehicleId', data: {
      if (plateNumber != null) 'plateNumber': plateNumber,
      if (capacityKg != null) 'capacityKg': capacityKg,
      if (volumeM3 != null) 'volumeM3': volumeM3,
      if (manufactureYear != null) 'manufactureYear': manufactureYear,
    });
  }

  Future<void> deleteVehicle(String vehicleId) async {
    await _api.dio.delete('/vehicles/$vehicleId');
  }

  Future<List<ReferenceEntry>> getVehicleTypes() async {
    final response = await _api.dio.get('/reference/vehicle-types');
    return (response.data as List<dynamic>)
        .map((e) => ReferenceEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ReferenceEntry>> getBodyTypes() async {
    final response = await _api.dio.get('/reference/body-types');
    return (response.data as List<dynamic>)
        .map((e) => ReferenceEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
