class ConversationResponse {
  final String conversationId;
  final String? shipmentId;
  final String type;
  final String status;
  final String createdAt;
  final String updatedAt;
  final List<Participant> participants;

  const ConversationResponse({
    required this.conversationId,
    required this.shipmentId,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.participants,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      conversationId: json['conversationId'] as String,
      shipmentId: json['shipmentId'] as String?,
      type: json['type'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => Participant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Participant {
  final String userId;
  final String role;
  final String? lastReadMessageId;
  final String? lastReadAt;
  final String joinedAt;

  const Participant({
    required this.userId,
    required this.role,
    this.lastReadMessageId,
    this.lastReadAt,
    required this.joinedAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userId: json['userId'] as String,
      role: json['role'] as String,
      lastReadMessageId: json['lastReadMessageId'] as String?,
      lastReadAt: json['lastReadAt'] as String?,
      joinedAt: json['joinedAt'] as String,
    );
  }
}

class MessageResponse {
  final String messageId;
  final String conversationId;
  final String senderUserId;
  final String body;
  final int sequence;
  final String createdAt;

  const MessageResponse({
    required this.messageId,
    required this.conversationId,
    required this.senderUserId,
    required this.body,
    required this.sequence,
    required this.createdAt,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      messageId: json['messageId'] as String,
      conversationId: json['conversationId'] as String,
      senderUserId: json['senderUserId'] as String,
      body: json['body'] as String,
      sequence: json['sequence'] as int,
      createdAt: json['createdAt'] as String,
    );
  }
}
