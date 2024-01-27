import 'dart:ffi';

import 'package:intl/intl.dart';

class PostModel {
  final int id;
  final bool isFromSchool;
  final String depart;
  final String arrive;
  final String departTime;
  final int cost;
  final int maxMember;
  final int nowMember;
  final bool isAuthor;

  PostModel({
    required this.id,
    required this.isFromSchool,
    required this.depart,
    required this.arrive,
    required this.departTime,
    required this.cost,
    required this.maxMember,
    required this.nowMember,
    required this.isAuthor,
  });

  factory PostModel.fromJson({
    required Map<String, dynamic> json,
  }) {
    return PostModel(
      id: json['id'],
      isFromSchool: json['isFromSchool'],
      depart: json['depart'],
      arrive: json['arrive'],
      departTime: formatDateTime(json['departTime']), //시간 포맷 어떻게 할지...,
      cost: json['cost'],
      maxMember: json['maxMember'],
      nowMember: json['nowMember'],
      isAuthor: json['isAuthor'],
    );
  }
  
  static String formatDateTime(String dateTimeString){
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedString = DateFormat('M/d HH:mm').format(dateTime);
    return formattedString;
  }
}
