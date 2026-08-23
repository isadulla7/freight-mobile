import '../../../core/network/api_client.dart';
import 'models/notification_models.dart';

class NotificationRepository {
  final ApiClient _api;

  NotificationRepository(this._api);

  Future<List<NotificationResponse>> getNotifications({
    bool unreadOnly = false,
  }) async {
    final response = await _api.dio.get('/notifications', queryParameters: {
      if (unreadOnly) 'unreadOnly': true,
    });
    final data = response.data as Map<String, dynamic>;
    return (data['notifications'] as List<dynamic>)
        .map((e) => NotificationResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await _api.dio.post('/notifications/$notificationId/read');
  }
}
