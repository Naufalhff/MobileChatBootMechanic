enum MessageSender { user, ai }

class ChatHistoryModel {
  final int id;
  final int? conversationId;
  final String query;
  final String normalizedQuery;
  final String response;
  final String? imagePath;
  final String motorModel;
  final String? aiModel;
  final String? aiModelResolved;
  final String? clientMessageId;
  final DateTime createdAt;

  ChatHistoryModel({
    required this.id,
    this.conversationId,
    required this.query,
    required this.normalizedQuery,
    required this.response,
    this.imagePath,
    required this.motorModel,
    this.aiModel,
    this.aiModelResolved,
    this.clientMessageId,
    required this.createdAt,
  });

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryModel(
      id: json['id'] as int,
      conversationId: (json['conversation_id'] as num?)?.toInt(),
      query: json['user_message'] as String? ?? '',
      normalizedQuery: json['normalized_message'] as String? ?? '',
      response: json['ai_response'] as String? ?? '',
      imagePath: json['image_url'] as String?,
      motorModel: json['motor_model'] as String? ?? 'Umum',
      aiModel: json['ai_model'] as String?,
      aiModelResolved: json['ai_model_resolved'] as String?,
      clientMessageId: json['client_message_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

class ChatSendResult {
  final List<ChatBubbleMessage> bubbles;
  final int? conversationId;

  const ChatSendResult({
    required this.bubbles,
    this.conversationId,
  });
}

class ChatBubbleMessage {
  final String text;
  final MessageSender sender;
  final String? imagePath;
  final String? normalizedText;
  final DateTime time;
  final String motorModel;
  final String? aiModel;
  final bool isTyping;

  ChatBubbleMessage({
    required this.text,
    required this.sender,
    this.imagePath,
    this.normalizedText,
    required this.time,
    required this.motorModel,
    this.aiModel,
    this.isTyping = false,
  });
}
