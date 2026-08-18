import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSource(this._apiClient);

  Future<List<ChatHistoryModel>> getHistory() async {
    final response = await _apiClient.get(ApiEndpoints.chatHistory);
    final list = response.data as List;
    return list
        .map((e) => ChatHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatHistoryModel> sendMessage({
    required String message,
    required String motorModel,
    String? localImagePath,
  }) async {
    final Map<String, dynamic> data = {
      'message': message,
      'motor_model': motorModel,
    };

    if (localImagePath != null && localImagePath.isNotEmpty) {
      data['image'] = await MultipartFile.fromFile(
        localImagePath,
        filename: localImagePath.split('/').last,
      );
    }

    final response = await _apiClient.postMultipart(
      ApiEndpoints.chatSend,
      data: data,
    );

    return ChatHistoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getSupportedMotors() async {
    final response = await _apiClient.get(ApiEndpoints.motor);
    final list = response.data as List;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }
}
