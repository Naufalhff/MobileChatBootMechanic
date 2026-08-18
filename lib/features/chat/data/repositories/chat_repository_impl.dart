import '../datasources/chat_remote_datasource.dart';
import '../models/chat_message_model.dart';

class ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepository(this._remoteDataSource);

  Future<List<ChatBubbleMessage>> getChatBubbles() async {
    final history = await _remoteDataSource.getHistory();
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
      ));
    }
    return bubbles;
  }

  Future<List<ChatBubbleMessage>> sendMessage({
    required String message,
    required String motorModel,
    String? localImagePath,
  }) async {
    final item = await _remoteDataSource.sendMessage(
      message: message,
      motorModel: motorModel,
      localImagePath: localImagePath,
    );

    return [
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
      ),
    ];
  }

  Future<List<Map<String, dynamic>>> getSupportedMotors() async {
    return await _remoteDataSource.getSupportedMotors();
  }
}
