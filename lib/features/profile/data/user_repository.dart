import '../../../core/network/api_client.dart';
import 'models/user_models.dart';

class UserRepository {
  final ApiClient _api;

  UserRepository(this._api);

  Future<UserResponse> getMe() async {
    final response = await _api.dio.get('/users/me');
    return UserResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DriverEligibilityResponse> getDriverEligibility() async {
    final response = await _api.dio.get('/users/me/driver-eligibility');
    return DriverEligibilityResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<String> createDriverProfile() async {
    final response = await _api.dio.post('/users/me/driver-profile');
    final data = response.data as Map<String, dynamic>;
    return data['profileId'] as String;
  }

  Future<void> assignRole(String roleCode) async {
    await _api.dio.post('/users/me/roles', data: {'roleCode': roleCode});
  }
}
