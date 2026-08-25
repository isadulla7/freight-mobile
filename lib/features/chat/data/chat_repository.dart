import '../../../core/network/api_client.dart';
import 'models/chat_models.dart';

class ChatRepository {
  final ApiClient _api;

  ChatRepository(this._api);

  Future<ConversationResponse> getOrCreateShipmentConversation({
    required String shipmentId,
    required List<Map<String, String>> participants,
  }) async {
    final response = await _api.dio.post('/conversations/shipment', data: {
      'shipmentId': shipmentId,
      'participants': participants,
    });
    return ConversationResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> sendMessage(String conversationId, String body) async {
    final response = await _api.dio.post(
      '/conversations/$conversationId/messages',
      data: {'body': body},
    );
    final data = response.data as Map<String, dynamic>;
    return data['messageId'] as String;
  }

  Future<List<MessageResponse>> getMessages(
    String conversationId, {
    int? afterSequence,
  }) async {
    final response = await _api.dio.get(
      '/conversations/$conversationId/messages',
      queryParameters: {
        'afterSequence': ?afterSequence,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return (data['messages'] as List<dynamic>)
        .map((e) => MessageResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ConversationResponse>> getConversations() async {
    final response = await _api.dio.get('/conversations');
    final data = response.data as Map<String, dynamic>;
    return (data['conversations'] as List<dynamic>)
        .map((e) => ConversationResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String conversationId, String lastReadMessageId) async {
    await _api.dio.post('/conversations/$conversationId/read', data: {
      'lastReadMessageId': lastReadMessageId,
    });
  }
}
