// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
      id: json['id'] as int,
      isFromSchool: json['isFromSchool'] as bool,
      depart: json['depart'] as String,
      arrive: json['arrive'] as String,
      departTime: PostModel.formatLocalDateTime(json['departTime'] as String),
      cost: json['cost'] as int,
      maxMember: json['maxMember'] as int,
      nowMember: json['nowMember'] as int,
      isAuthor: json['isAuthor'] as bool,
    );

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
      'id': instance.id,
      'isFromSchool': instance.isFromSchool,
      'depart': instance.depart,
      'arrive': instance.arrive,
      'departTime': PostModel.dateTimeToLocalDateTime(instance.departTime),
      'cost': instance.cost,
      'maxMember': instance.maxMember,
      'nowMember': instance.nowMember,
      'isAuthor': instance.isAuthor,
    };