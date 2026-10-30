class ConversationModel {
  final int id;
  final String? title;
  final String? motorModel;
  final String? aiModel;
  final int messageCount;
  final String? lastMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ConversationModel({
    required this.id,
    this.title,
    this.motorModel,
    this.aiModel,
    this.messageCount = 0,
    this.lastMessage,
    this.createdAt,
    this.updatedAt,
  });

  String get displayTitle {
    final value = (title ?? '').trim();
    if (value.isNotEmpty) return value;
    return motorModel?.trim().isNotEmpty == true
        ? 'Konsultasi ${motorModel!}'
        : 'Konsultasi';
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return ConversationModel(
      id: json['id'] as int,
      title: json['title'] as String?,
      motorModel: json['motor_model'] as String?,
      aiModel: json['ai_model'] as String?,
      messageCount: (json['message_count'] as num?)?.toInt() ?? 0,
      lastMessage: json['last_message'] as String?,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}
