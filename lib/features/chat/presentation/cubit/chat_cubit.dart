import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/repositories/chat_repository_impl.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatBubbleMessage> messages;
  final List<Map<String, dynamic>> supportedMotors;
  ChatLoaded(this.messages, this.supportedMotors);
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;

  ChatCubit(this._chatRepository) : super(ChatInitial());

  Future<void> loadChat() async {
    emit(ChatLoading());
    try {
      final messages = await _chatRepository.getChatBubbles();
      final motors = await _chatRepository.getSupportedMotors();
      emit(ChatLoaded(messages, motors));
    } catch (e) {
      emit(ChatError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> sendMessage({
    required String message,
    required String motorModel,
    String? localImagePath,
  }) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      final List<ChatBubbleMessage> currentMessages =
          List.from(currentState.messages);
      final motors = currentState.supportedMotors;

      final tempUserBubble = ChatBubbleMessage(
        text: message,
        sender: MessageSender.user,
        imagePath: localImagePath,
        time: DateTime.now(),
        motorModel: motorModel,
      );
      currentMessages.add(tempUserBubble);

      final typingBubble = ChatBubbleMessage(
        text: 'Sedang mengetik...',
        sender: MessageSender.ai,
        time: DateTime.now().add(const Duration(milliseconds: 1)),
        motorModel: motorModel,
        isTyping: true,
      );
      currentMessages.add(typingBubble);

      emit(ChatLoaded(currentMessages, motors));

      try {
        final newBubbles = await _chatRepository.sendMessage(
          message: message,
          motorModel: motorModel,
          localImagePath: localImagePath,
        );

        if (currentMessages.isNotEmpty && currentMessages.last.isTyping) {
          currentMessages.removeLast();
        }

        currentMessages.addAll(newBubbles);
        emit(ChatLoaded(currentMessages, motors));
      } catch (e) {
        if (currentMessages.isNotEmpty && currentMessages.last.isTyping) {
          currentMessages.removeLast();
        }
        currentMessages.add(
          ChatBubbleMessage(
            text: 'Gagal mengirim pesan: ${e.toString().replaceAll('Exception: ', '')}',
            sender: MessageSender.ai,
            time: DateTime.now(),
            motorModel: motorModel,
          ),
        );
        emit(ChatLoaded(currentMessages, motors));
      }
    }
  }
}
