import '../../../core/network/api_client.dart';
import 'models/company_models.dart';

class CompanyRepository {
  final ApiClient _api;

  CompanyRepository(this._api);

  Future<String> createCompany(CreateCompanyPayload payload) async {
    final response = await _api.dio.post('/companies', data: payload.toJson());
    final data = response.data as Map<String, dynamic>;
    return data['companyId'] as String;
  }

  Future<CompanyResponse> getCompany(String companyId) async {
    final response = await _api.dio.get('/companies/$companyId');
    return CompanyResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> addMember(String companyId, String userId) async {
    await _api.dio.post('/companies/$companyId/members', data: {
      'userId': userId,
    });
  }

  Future<void> removeMember(String companyId, String userId) async {
    await _api.dio.delete('/companies/$companyId/members/$userId');
  }

  Future<void> assignMemberRole(
    String companyId,
    String userId,
    String roleCode,
  ) async {
    await _api.dio.post('/companies/$companyId/members/$userId/roles', data: {
      'roleCode': roleCode,
    });
  }
}
