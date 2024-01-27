import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//isFromSchool, depart, arrive, departTime, maxMember, nowMember

class PostCard extends StatelessWidget {
  final bool isFromSchool;
  final String depart;
  final String arrive;
  final String departTime;
  final int maxMember;
  final int nowMember;
  final bool isAuthor;

  const PostCard(
      {required this.isFromSchool,
      required this.depart,
      required this.arrive,
      required this.departTime,
      required this.maxMember,
      required this.nowMember,
      required this.isAuthor,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: _MainText(
              isFromSchool: isFromSchool,
              depart: depart,
              arrive: arrive,
            ),
          ),
          if (isAuthor)
            FaIcon(
              FontAwesomeIcons.crown,
              size: 16.0,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$departTime 출발',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
                ),
                Text('현재인원 $nowMember/$maxMember'),
              ],
            ),
          ),
        ],
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
        ),
      );
    else //학교로 도착
      return Text(
        '$depart 출발',
        style: TextStyle(
          fontSize: 18.0,
        ),
      );
  }
}
