import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/message_response_model.dart';

// 메시지 리스트를 관리하는 상태 관리 객체
final chatMessagesProvider = StateNotifierProvider<ChatMessagesStateNotifier, List<MessageResponseModel>>((ref) {
  return ChatMessagesStateNotifier();
});

// StateNotifier 구현
class ChatMessagesStateNotifier extends StateNotifier<List<MessageResponseModel>> {
  ChatMessagesStateNotifier() : super([]);

  // 새 메시지 추가 메소드
  void addMessage(MessageResponseModel message) {
    state = [...state, message];
  }
}