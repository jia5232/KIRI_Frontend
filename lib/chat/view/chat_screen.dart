import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiri/common/const/colors.dart';

import '../component/chat_message.dart';
import '../model/message_response_model.dart';
import '../provider/chat_messages_state_notifier_provider.dart';
import '../websocket/web_socket_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
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
      //인덱스 0이 아니라 리스트 제일 뒤에 넣고싶어!
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
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
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
                    size: 20.0,
                  ),
                ),
                Text("보문역"),
                SizedBox(width: 8.0),
                Icon(
                  Icons.person,
                  size: 20.0,
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
    //새로운 메시지가 AnimatedList에 추가될 때, 리스트의 높이가 바뀌고 maxScrollExtent도 업데이트되어야 하는데,
    // 만약 스크롤을 높이가 변경되기 전에 호출하면, 스크롤은 완전한 높이를 인식하지 못하고 중간에서 멈출 수 있기 때문에 짧은 delay를 주고 새로운 높이를 계산할 시간을 준다.
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent, // 맨 밑으로 스크롤
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
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
            print("clicked!!");
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ],
    );
  }
}
