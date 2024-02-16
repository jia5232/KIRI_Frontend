import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiri/common/const/colors.dart';

import '../component/chat_message.dart';
import '../model/message_response_model.dart';
import '../provider/chat_messages_state_notifier_provider.dart';
import '../websocket/web_socket_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  static String get routeName => 'chat';

  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>();
  ScrollController _scrollController = ScrollController();
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final webSocketService = ref.read(webSocketServiceProvider);
    webSocketService.setOnMessageReceivedCallback((MessageResponseModel message) {
      final messages = ref.read(chatMessagesProvider.notifier);
      messages.addMessage(message);
      _animatedListKey.currentState?.insertItem(messages.state.length-1);
    });

    final chatRoomId = ref.read(chatRoomIdProvider);
    webSocketService.connect(chatRoomId);
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Top(),
            _buildTitle(context),
            Expanded(
              child: AnimatedList(
                key: _animatedListKey,
                reverse: false,
                controller: _scrollController,
                initialItemCount: messages.length,
                itemBuilder: (context, index, animation) {
                  final message = messages[index];
                  return ChatMessage(
                    content: message.content,
                    nickname: message.nickname,
                    createdTime: message.createdTime,
                    animation: animation,
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        hintText: "메시지 입력",
                      ),
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  TextButton(
                    onPressed: () {
                      _handleSubmitted(_textEditingController.text);
                    },
                    child: Text("전송"),
                    style: TextButton.styleFrom(
                      backgroundColor: PRIMARY_COLOR,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade400),
          bottom: BorderSide(color: Colors.grey.shade400),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text("국민대학교"),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 18.0,
                  ),
                ),
                Text("보문역"),
                SizedBox(width: 8.0),
                Icon(
                  Icons.person,
                  size: 18.0,
                ),
                Text("3"),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("2024.01.19"),
                Text('13:00 만남'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) {
      return; // 빈 메시지는 전송하지 않음
    }

    print(text);
    _textEditingController.clear();

    final chatRoomId = ref.read(chatRoomIdProvider); // 현재 채팅방 ID
    final webSocketService = ref.read(webSocketServiceProvider);

    webSocketService.sendMessage(chatRoomId, text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // 스크롤이 필요한지 확인
    if (_scrollController.hasClients) {
      // 현재 프레임이 렌더링된 후에 실행될 콜백을 스케줄링
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }
}

class _Top extends StatelessWidget {
  const _Top({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            context.goNamed('home');
            // bottom Navigator bar 인덱스 1번으로 가게 하고싶당...
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ],
    );
  }
}
