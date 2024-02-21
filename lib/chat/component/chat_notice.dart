import 'package:flutter/material.dart';
import 'package:kiri/common/const/colors.dart';

class ChatNotice extends StatelessWidget {
  final String content;

  const ChatNotice({
    required this.content,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            content,
            style: TextStyle(
              color: BODY_TEXT_COLOR,
              fontSize: 14.0,
            ),
          ),
        ),
      ],
    );
  }
}