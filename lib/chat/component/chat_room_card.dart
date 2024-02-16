import 'package:flutter/material.dart';
import 'package:kiri/common/const/colors.dart';

class ChatRoomCard extends StatelessWidget {
  const ChatRoomCard({super.key});

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
                    color: PRIMARY_COLOR,
                    size: 18.0,
                  ),
                  Text("3"),
                ],
              ),
              Text(
                '2024.01.19일 13:00 출발',
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
                '네 그럼 용두리 앞에서 뵙겠습니다~',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
