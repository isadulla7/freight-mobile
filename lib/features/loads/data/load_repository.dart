import '../../../core/network/api_client.dart';
import 'models/load_models.dart';

class LoadRepository {
  final ApiClient _api;

  LoadRepository(this._api);

  Future<String> createLoad(CreateLoadPayload payload) async {
    final response = await _api.dio.post('/loads', data: payload.toJson());
    final data = response.data as Map<String, dynamic>;
    return data['loadId'] as String;
  }

  Future<LoadResponse> getLoad(String loadId) async {
    final response = await _api.dio.get('/loads/$loadId');
    return LoadResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> updateDraftLoad(String loadId, CreateLoadPayload payload) async {
    await _api.dio.patch('/loads/$loadId', data: payload.toJson());
  }

  Future<void> publishLoad(String loadId) async {
    await _api.dio.post('/loads/$loadId/publish');
  }

  Future<void> cancelLoad(String loadId) async {
    await _api.dio.post('/loads/$loadId/cancel');
  }

  Future<List<String>> searchLoads({
    required double latitude,
    required double longitude,
    double radiusMeters = 50000,
    int limit = 50,
  }) async {
    final response = await _api.dio.get('/loads/search', queryParameters: {
      'pickupLatitude': latitude,
      'pickupLongitude': longitude,
      'radiusMeters': radiusMeters,
      'limit': limit,
    });
    final data = response.data as Map<String, dynamic>;
    return (data['loadIds'] as List<dynamic>).cast<String>();
  }

  Future<List<LoadResponse>> searchAndFetchLoads({
    required double latitude,
    required double longitude,
    double radiusMeters = 50000,
    int limit = 20,
  }) async {
    final ids = await searchLoads(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      limit: limit,
    );
    final loads = <LoadResponse>[];
    for (final id in ids) {
      try {
        loads.add(await getLoad(id));
      } catch (_) {}
    }
    return loads;
  }
}
