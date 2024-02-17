import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiri/chat/component/chat_room_card.dart';
import 'package:kiri/chat/provider/chat_room_state_notifier_provider.dart';
import 'package:kiri/chat/websocket/web_socket_service.dart';

import '../../common/const/colors.dart';
import '../../common/model/cursor_pagination_model.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'chatList';

  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final ScrollController controller = ScrollController();

  void scrollListener() {
    // 현재 위치가 최대 길이보다 조금 덜되는 위치까지 왔다면 새로운 데이터를 추가 요청.
    // 현재 컨트롤러 위치가(controller.offset) 컨트롤러의 최대 크기 - n 보다 크면 요청을 보낸다.
    if (controller.offset > controller.position.maxScrollExtent - 150) {
      ref.read(chatRoomStateNotifierProvider.notifier).paginate(
            fetchMore: true,
          );
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(chatRoomStateNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Top(),
            Expanded(
              child: _buildChatRoomList(data, ref, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatRoomList(
      CursorPaginationModelBase data, WidgetRef ref, BuildContext context) {
    final data = ref.watch(chatRoomStateNotifierProvider);

    if (data is CursorPaginationModelLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: PRIMARY_COLOR,
        ),
      );
    }

    if (data is CursorPaginationModelError) {
      return Center(
        child: Text("데이터를 불러올 수 없습니다."),
      );
    }

    final cp = data as CursorPaginationModel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.separated(
        controller: controller,
        itemCount: cp.data.length + 1,
        itemBuilder: (_, index) {
          if (index == cp.data.length) {
            return Center(
              child: cp is CursorPaginationModelFetchingMore
                  ? CircularProgressIndicator(
                      color: PRIMARY_COLOR,
                    )
                  : Text(
                      'Copyright 2024. JiaKwon all rights reserved.\n',
                      style: TextStyle(
                        color: BODY_TEXT_COLOR,
                        fontSize: 12.0,
                      ),
                    ),
            );
          }

          final pItem = cp.data[index];

          return GestureDetector(
            child: ChatRoomCard.fromModel(chatRoomModel: pItem),
            onTap: (){
              ref.read(chatRoomIdProvider.notifier).state = pItem.chatRoomId; //이렇게는 못하나???
              context.goNamed('chat');
            },
          );
        },
        separatorBuilder: (_, index) {
          return SizedBox(height: 16.0);
        },
      ),
    );
  }
}

class _Top extends StatelessWidget {
  const _Top({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.0),
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.grey.shade400),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
        ),
      ),
      child: Row(
        children: [
          Text(
            '채팅',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ],
      ),
    );
  }
}
