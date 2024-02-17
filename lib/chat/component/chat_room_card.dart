import 'package:flutter/material.dart';
import 'package:kiri/chat/model/chat_room_model.dart';
import 'package:kiri/common/const/colors.dart';

class ChatRoomCard extends StatelessWidget {
  final int chatRoomId;
  final String depart;
  final String arrive;
  final String departTime;
  final int nowMember;
  final String lastMessageContent;
  final String messageCreatedTime;

  const ChatRoomCard({
    required this.chatRoomId,
    required this.depart,
    required this.arrive,
    required this.departTime,
    required this.nowMember,
    required this.lastMessageContent,
    required this.messageCreatedTime,
    super.key,
  });

  factory ChatRoomCard.fromModel({required ChatRoomModel chatRoomModel}) {
    return ChatRoomCard(
      chatRoomId: chatRoomModel.chatRoomId,
      depart: chatRoomModel.depart,
      arrive: chatRoomModel.arrive,
      departTime: chatRoomModel.departTime,
      nowMember: chatRoomModel.nowMember,
      lastMessageContent: chatRoomModel.lastMessageContent,
      messageCreatedTime: chatRoomModel.messageCreatedTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      width: MediaQuery.of(context).size.width,
      height: 86.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.grey.shade400),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(depart),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 18.0,
                    ),
                  ),
                  Text(arrive),
                  SizedBox(width: 8.0),
                  Icon(
                    Icons.person,
                    color: PRIMARY_COLOR,
                    size: 18.0,
                  ),
                  Text(nowMember.toString()),
                ],
              ),
              Text(
                '${departTime.split(" ")[0]}일 ${departTime.split(" ")[1]} 출발',
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                lastMessageContent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
