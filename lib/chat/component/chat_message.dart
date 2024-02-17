import 'package:flutter/material.dart';
import 'package:kiri/common/const/colors.dart';

class ChatMessage extends StatelessWidget {
  final String content;
  final String nickname;
  final DateTime createdTime;

  const ChatMessage({
    required this.content,
    required this.nickname,
    required this.createdTime,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: PRIMARY_COLOR,
            child: Text(nickname[0].toUpperCase()), // 닉네임의 첫 글자 사용
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      nickname,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      '${createdTime.year}-${createdTime.month}-${createdTime.day} ${createdTime.hour}:${createdTime.minute}',
                      style: TextStyle(
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
                Text(content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}