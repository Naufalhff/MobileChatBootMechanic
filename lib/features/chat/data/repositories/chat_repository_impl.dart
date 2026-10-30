import '../datasources/chat_remote_datasource.dart';
import '../models/ai_model_model.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';

class ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepository(this._remoteDataSource);

  Future<List<ChatBubbleMessage>> getChatBubbles({int? conversationId}) async {
    final history = await _remoteDataSource.getHistory(
      conversationId: conversationId,
    );
    final List<ChatBubbleMessage> bubbles = [];

    for (final item in history) {
      bubbles.add(ChatBubbleMessage(
        text: item.query,
        sender: MessageSender.user,
        imagePath: item.imagePath,
        time: item.createdAt,
        motorModel: item.motorModel,
      ));
      bubbles.add(ChatBubbleMessage(
        text: item.response,
        sender: MessageSender.ai,
        normalizedText:
            item.normalizedQuery != item.query ? item.normalizedQuery : null,
        time: item.createdAt.add(const Duration(seconds: 1)),
        motorModel: item.motorModel,
        aiModel: item.aiModelResolved ?? item.aiModel,
      ));
    }
    return bubbles;
  }

  Future<ChatSendResult> sendMessage({
    required String message,
    required String motorModel,
    String? model,
    int? conversationId,
    String? clientMessageId,
    String? localImagePath,
  }) async {
    final item = await _remoteDataSource.sendMessage(
      message: message,
      motorModel: motorModel,
      model: model,
      conversationId: conversationId,
      clientMessageId: clientMessageId,
      localImagePath: localImagePath,
    );

    return ChatSendResult(
      conversationId: item.conversationId ?? conversationId,
      bubbles: [
        ChatBubbleMessage(
          text: item.query,
          sender: MessageSender.user,
          imagePath: localImagePath ?? item.imagePath,
          time: item.createdAt,
          motorModel: item.motorModel,
        ),
        ChatBubbleMessage(
          text: item.response,
          sender: MessageSender.ai,
          normalizedText:
              item.normalizedQuery != item.query ? item.normalizedQuery : null,
          time: item.createdAt.add(const Duration(seconds: 1)),
          motorModel: item.motorModel,
          aiModel: item.aiModelResolved ?? item.aiModel,
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> getSupportedMotors() async {
    return await _remoteDataSource.getSupportedMotors();
  }

  Future<AiModelCatalog> getAvailableModels() async {
    return await _remoteDataSource.getAvailableModels();
  }

  Future<List<ConversationModel>> getConversations() async {
    return await _remoteDataSource.getConversations();
  }

  Future<void> deleteConversation(int conversationId) async {
    await _remoteDataSource.deleteConversation(conversationId);
  }

  Future<void> clearHistory() async {
    await _remoteDataSource.clearHistory();
  }
}
