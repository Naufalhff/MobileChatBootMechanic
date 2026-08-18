enum MessageSender { user, ai }

class ChatHistoryModel {
  final int id;
  final String query;
  final String normalizedQuery;
  final String response;
  final String? imagePath;
  final String motorModel;
  final DateTime createdAt;

  ChatHistoryModel({
    required this.id,
    required this.query,
    required this.normalizedQuery,
    required this.response,
    this.imagePath,
    required this.motorModel,
    required this.createdAt,
  });

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryModel(
      id: json['id'] as int,
      query: json['user_message'] as String? ?? '',
      normalizedQuery: json['normalized_message'] as String? ?? '',
      response: json['ai_response'] as String? ?? '',
      imagePath: json['image_url'] as String?,
      motorModel: json['motor_model'] as String? ?? 'Umum',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

class ChatBubbleMessage {
  final String text;
  final MessageSender sender;
  final String? imagePath;
  final String? normalizedText;
  final DateTime time;
  final String motorModel;
  final bool isTyping;

  ChatBubbleMessage({
    required this.text,
    required this.sender,
    this.imagePath,
    this.normalizedText,
    required this.time,
    required this.motorModel,
    this.isTyping = false,
  });
}
