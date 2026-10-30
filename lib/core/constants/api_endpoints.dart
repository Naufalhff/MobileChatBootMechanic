import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://192.168.1.7:8000/api/v1';

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String chatSend = '/chat/send';
  static const String chatHistory = '/chat/history';
  static const String chatModels = '/chat/models';
  static const String chatConversations = '/chat/conversations';
  static const String motor = '/motor/';
}
