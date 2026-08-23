import '../../../core/network/api_client.dart';
import 'models/offer_models.dart';

class OfferRepository {
  final ApiClient _api;

  OfferRepository(this._api);

  Future<String> createOffer(CreateOfferPayload payload) async {
    final response = await _api.dio.post('/offers', data: payload.toJson());
    final data = response.data as Map<String, dynamic>;
    return data['offerId'] as String;
  }

  Future<OfferResponse> getOffer(String offerId) async {
    final response = await _api.dio.get('/offers/$offerId');
    return OfferResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<OfferResponse>> getOffersForLoad(String loadId) async {
    final response = await _api.dio.get('/offers/by-load/$loadId');
    final data = response.data as Map<String, dynamic>;
    return (data['offers'] as List<dynamic>)
        .map((e) => OfferResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> acceptOffer(String offerId, int expectedLoadVersion) async {
    await _api.dio.post(
      '/offers/$offerId/accept',
      data: {'expectedLoadVersion': expectedLoadVersion},
    );
  }

  Future<void> rejectOffer(String offerId) async {
    await _api.dio.post('/offers/$offerId/reject');
  }

  Future<void> withdrawOffer(String offerId) async {
    await _api.dio.post('/offers/$offerId/withdraw');
  }
}
