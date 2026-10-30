import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/conversation_model.dart';
import '../../data/repositories/chat_repository_impl.dart';

abstract class ConversationState {}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationLoaded extends ConversationState {
  final List<ConversationModel> conversations;
  ConversationLoaded(this.conversations);
}

class ConversationError extends ConversationState {
  final String message;
  ConversationError(this.message);
}

class ConversationCubit extends Cubit<ConversationState> {
  final ChatRepository _chatRepository;

  ConversationCubit(this._chatRepository) : super(ConversationInitial());

  Future<void> load() async {
    emit(ConversationLoading());
    try {
      final conversations = await _chatRepository.getConversations();
      emit(ConversationLoaded(conversations));
    } catch (e) {
      emit(ConversationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> delete(int conversationId) async {
    try {
      await _chatRepository.deleteConversation(conversationId);
      emit(ConversationLoaded(
        _currentConversations
            .where((item) => item.id != conversationId)
            .toList(),
      ));
    } catch (e) {
      emit(ConversationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> clearAll() async {
    try {
      await _chatRepository.clearHistory();
      emit(ConversationLoaded(const []));
    } catch (e) {
      emit(ConversationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  List<ConversationModel> get _currentConversations {
    final currentState = state;
    if (currentState is ConversationLoaded) {
      return currentState.conversations;
    }
    return const [];
  }
}
