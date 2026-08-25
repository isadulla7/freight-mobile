import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import 'models/auth_models.dart';

class AuthRepository {
  final ApiClient _api;

  AuthRepository(this._api);

  Future<bool> requestOtp(String phoneNumber) async {
    try {
      final response = await _api.dio.post(
        '/auth/otp/request',
        data: {'phoneNumber': phoneNumber},
      );
      final data = response.data as Map<String, dynamic>;
      return data['sent'] as bool;
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  Future<SessionTokens> verifyOtp({
    required String phoneNumber,
    required String otp,
    String? deviceLabel,
  }) async {
    try {
      final response = await _api.dio.post(
        '/auth/otp/verify',
        data: {
          'phoneNumber': phoneNumber,
          'otp': otp,
          'deviceLabel': ?deviceLabel,
        },
      );
      final tokens = SessionTokens.fromJson(response.data as Map<String, dynamic>);
      await _api.saveTokens(tokens.accessToken, tokens.refreshToken);
      return tokens;
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } finally {
      await _api.clearTokens();
    }
  }

  Future<List<DeviceSession>> getSessions() async {
    try {
      final response = await _api.dio.get('/auth/sessions');
      final data = response.data as Map<String, dynamic>;
      final sessions = data['sessions'] as List<dynamic>;
      return sessions
          .map((e) => DeviceSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> revokeSession(String sessionId) async {
    try {
      await _api.dio.delete('/auth/sessions/$sessionId');
    } on Exception catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> isAuthenticated() => _api.hasToken();

  Exception _handleError(Exception e) {
    if (e is ApiException) return e;
    return e;
  }
}
