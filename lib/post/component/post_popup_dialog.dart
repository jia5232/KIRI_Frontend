import 'package:flutter/material.dart';
import 'package:kiri/common/const/colors.dart';

class PostPopupDialog extends StatelessWidget {
  final bool isFromSchool;
  final String depart;
  final String arrive;
  final String departTime;
  final int maxMember;
  final int nowMember;
  final int cost;
  final VoidCallback onPressed;

  const PostPopupDialog({
    required this.isFromSchool,
    required this.depart,
    required this.arrive,
    required this.departTime,
    required this.maxMember,
    required this.nowMember,
    required this.cost,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final discountedPrice = (cost / maxMember).toInt();

    final costTextStyle = TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: PRIMARY_COLOR,
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        //Dialog 화면의 border
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        padding: EdgeInsets.all(20.0),
        width: MediaQuery.of(context).size.width * 0.7,
        height: 200.0,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius:
              BorderRadius.all(Radius.circular(12.0)), //Dialog 내부 컨테이너의 border
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MainText(
              isFromSchool: isFromSchool,
              depart: depart,
              arrive: arrive,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$departTime 출발',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 10.0),
                Text(
                  '현재인원 $nowMember/$maxMember',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Text(
                  '$maxMember명 모이면 $discountedPrice원/',
                  style: costTextStyle,
                ),
                Text(
                  '$cost',
                  style: costTextStyle.copyWith(
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                Text(
                  '원 예상',
                  style: costTextStyle,
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: onPressed,
              child: Text('참여하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainText extends StatelessWidget {
  final bool isFromSchool;
  final String depart;
  final String arrive;

  const _MainText(
      {required this.isFromSchool,
      required this.depart,
      required this.arrive,
      super.key});

  @override
  Widget build(BuildContext context) {
    if (isFromSchool) //학교에서 출발
      return Text(
        '$arrive 도착',
        style: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.w500,
        ),
      );
    else //학교로 도착
      return Text(
        '$depart 출발',
        style: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.w500,
        ),
      );
  }
}
