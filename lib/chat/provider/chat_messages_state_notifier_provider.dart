import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/message_response_model.dart';

// 메시지 리스트를 관리
final chatMessagesProvider = StateNotifierProvider<ChatMessagesStateNotifier, List<MessageResponseModel>>((ref) {
  return ChatMessagesStateNotifier();
});

class ChatMessagesStateNotifier extends StateNotifier<List<MessageResponseModel>> {
  ChatMessagesStateNotifier() : super([]);

  // 새 메시지 추가 메소드
  void addMessage(MessageResponseModel message) {
    if (!state.any((m) => m.id == message.id)) {
      state = [...state, message];
    }
  }

  // 메시지 리스트 설정 메소드
  void setMessages(List<MessageResponseModel> messages) {
    state = messages;
  }
}