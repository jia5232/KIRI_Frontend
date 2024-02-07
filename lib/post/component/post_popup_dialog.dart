import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kiri/common/const/colors.dart';

class PostPopupDialog extends StatelessWidget {
  final bool isFromSchool;
  final String depart;
  final String arrive;
  final String departTime;
  final int maxMember;
  final int nowMember;
  final int cost;
  final bool isAuthor;
  final VoidCallback joinOnPressed;
  final VoidCallback deleteOnPressed;

  const PostPopupDialog({
    required this.isFromSchool,
    required this.depart,
    required this.arrive,
    required this.departTime,
    required this.maxMember,
    required this.nowMember,
    required this.cost,
    required this.isAuthor,
    required this.joinOnPressed,
    required this.deleteOnPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final departTimeList = departTime.split(' ');
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _MainText(
                  isFromSchool: isFromSchool,
                  depart: depart,
                  arrive: arrive,
                ),
                if (isAuthor)
                  SizedBox(
                      height: 30.0,
                      width: 60.0,
                      child: IconButton(
                        onPressed: deleteOnPressed,
                        icon: FaIcon(
                          FontAwesomeIcons.trash,
                          size: 20.0,
                          color: Colors.red,
                        ),
                      )),
              ],
            ),
            SizedBox(
              height: 6.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${departTimeList[0]}일 ${departTimeList[1]}출발',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 10.0),
                Text(
                  '현재 $nowMember/$maxMember',
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
            SizedBox(height: 20.0),
            SizedBox(
              height: 40.0,
              child: ElevatedButton(
                onPressed: joinOnPressed,
                child: Text(
                  '참여하기',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
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
          fontSize: 18.0,
          fontWeight: FontWeight.w900,
        ),
      );
    else //학교로 도착
      return Text(
        '$depart 출발',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w900,
        ),
      );
  }
}
