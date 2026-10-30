import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/ai_model_model.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/repositories/chat_repository_impl.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatBubbleMessage> messages;
  final List<Map<String, dynamic>> supportedMotors;
  final List<AiModel> aiModels;
  final String? defaultModel;
  final int? conversationId;
  final bool isSending;

  ChatLoaded(
    this.messages,
    this.supportedMotors, {
    this.aiModels = const [],
    this.defaultModel,
    this.conversationId,
    this.isSending = false,
  });
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final Random _random = Random();

  ChatCubit(this._chatRepository) : super(ChatInitial());

  String _newClientMessageId() {
    return '${DateTime.now().microsecondsSinceEpoch}-'
        '${_random.nextInt(1 << 32)}';
  }

  Future<void> loadChat({int? conversationId}) async {
    emit(ChatLoading());
    try {
      final motors = await _chatRepository.getSupportedMotors();
      final messages = conversationId == null
          ? <ChatBubbleMessage>[]
          : await _chatRepository.getChatBubbles(
              conversationId: conversationId,
            );

      List<AiModel> aiModels = const [];
      String? defaultModel;
      try {
        final catalog = await _chatRepository.getAvailableModels();
        aiModels = catalog.models;
        defaultModel =
            catalog.defaultModel.isEmpty ? null : catalog.defaultModel;
      } catch (_) {
        // Daftar model gagal dimuat: chat tetap jalan dengan model default backend.
      }

      emit(ChatLoaded(
        messages,
        motors,
        aiModels: aiModels,
        defaultModel: defaultModel,
        conversationId: conversationId,
      ));
    } catch (e) {
      emit(ChatError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> sendMessage({
    required String message,
    required String motorModel,
    String? model,
    String? localImagePath,
  }) async {
    final currentState = state;
    if (currentState is! ChatLoaded || currentState.isSending) {
      return;
    }

    final List<ChatBubbleMessage> currentMessages =
        List.from(currentState.messages);
    final motors = currentState.supportedMotors;
    final aiModels = currentState.aiModels;
    final defaultModel = currentState.defaultModel;
    final conversationId = currentState.conversationId;

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

    emit(ChatLoaded(
      currentMessages,
      motors,
      aiModels: aiModels,
      defaultModel: defaultModel,
      conversationId: conversationId,
      isSending: true,
    ));

    try {
      final result = await _chatRepository.sendMessage(
        message: message,
        motorModel: motorModel,
        model: model,
        conversationId: conversationId,
        clientMessageId: _newClientMessageId(),
        localImagePath: localImagePath,
      );

      if (currentMessages.isNotEmpty && currentMessages.last.isTyping) {
        currentMessages.removeLast();
      }
      currentMessages.addAll(result.bubbles);

      emit(ChatLoaded(
        currentMessages,
        motors,
        aiModels: aiModels,
        defaultModel: defaultModel,
        conversationId: result.conversationId ?? conversationId,
      ));
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
          aiModel: model,
        ),
      );
      emit(ChatLoaded(
        currentMessages,
        motors,
        aiModels: aiModels,
        defaultModel: defaultModel,
        conversationId: conversationId,
      ));
    }
  }
}
