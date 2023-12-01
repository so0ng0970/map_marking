// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordModel _$RecordModelFromJson(Map<String, dynamic> json) => RecordModel(
      title: json['title'] as String,
      content: json['content'] as String,
      postId: json['postId'] as String,
      tag: json['tag'] as String,
      location: (json['location'] as num).toDouble(),
      imgUrl:
          (json['imgUrl'] as List<dynamic>?)?.map((e) => e as String).toList(),
      dataTime: RecordModel._fromJsonTimestamp(json['dataTime'] as Timestamp),
    );

Map<String, dynamic> _$RecordModelToJson(RecordModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'postId': instance.postId,
      'tag': instance.tag,
      'location': instance.location,
      'imgUrl': instance.imgUrl,
      'dataTime': RecordModel._toJsonTimestamp(instance.dataTime),
    };
