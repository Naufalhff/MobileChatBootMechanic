import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/ai_model_model.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';

class ChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSource(this._apiClient);

  Future<List<ChatHistoryModel>> getHistory({
    int? conversationId,
    int limit = 200,
    int offset = 0,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.chatHistory,
      queryParameters: {
        if (conversationId != null) 'conversation_id': conversationId,
        'limit': limit,
        'offset': offset,
      },
    );
    final list = response.data as List;
    return list
        .map((e) => ChatHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ConversationModel>> getConversations() async {
    final response = await _apiClient.get(ApiEndpoints.chatConversations);
    final list = response.data as List;
    return list
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteConversation(int conversationId) async {
    await _apiClient.delete('${ApiEndpoints.chatConversations}/$conversationId');
  }

  Future<void> clearHistory() async {
    await _apiClient.delete(ApiEndpoints.chatHistory);
  }

  Future<ChatHistoryModel> sendMessage({
    required String message,
    required String motorModel,
    String? model,
    int? conversationId,
    String? clientMessageId,
    String? localImagePath,
  }) async {
    final Map<String, dynamic> data = {
      'message': message,
      'motor_model': motorModel,
    };

    if (model != null && model.isNotEmpty) {
      data['model'] = model;
    }

    if (conversationId != null) {
      data['conversation_id'] = conversationId;
    }

    if (clientMessageId != null && clientMessageId.isNotEmpty) {
      data['client_message_id'] = clientMessageId;
    }

    if (localImagePath != null && localImagePath.isNotEmpty) {
      data['image'] = await MultipartFile.fromFile(
        localImagePath,
        filename: localImagePath.split('/').last,
      );
    }

    final response = await _apiClient.postMultipart(
      ApiEndpoints.chatSend,
      data: data,
      // 9Router bisa butuh waktu lama, terutama untuk model reasoning.
      options: Options(
        contentType: 'multipart/form-data',
        receiveTimeout: const Duration(seconds: 170),
      ),
    );

    return ChatHistoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AiModelCatalog> getAvailableModels() async {
    final response = await _apiClient.get(
      ApiEndpoints.chatModels,
      options: Options(receiveTimeout: const Duration(seconds: 40)),
    );
    return AiModelCatalog.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getSupportedMotors() async {
    final response = await _apiClient.get(ApiEndpoints.motor);
    final list = response.data as List;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }
}
