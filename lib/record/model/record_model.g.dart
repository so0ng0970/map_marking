// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordModel _$RecordModelFromJson(Map<String, dynamic> json) => RecordModel(
      title: json['title'] as String,
      content: json['content'] as String,
      markerLatitude: (json['markerLatitude'] as num).toDouble(),
      markerLongitude: (json['markerLongitude'] as num).toDouble(),
      selected: json['selected'] as String,
      imgUrl:
          (json['imgUrl'] as List<dynamic>?)?.map((e) => e as String).toList(),
      postId: json['postId'] as String?,
      markerId: json['markerId'] as String,
      selectedColor: json['selectedColor'] as int,
      dataTime: RecordModel._fromJsonTimestamp(json['dataTime'] as Timestamp),
    );

Map<String, dynamic> _$RecordModelToJson(RecordModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'markerLatitude': instance.markerLatitude,
      'markerLongitude': instance.markerLongitude,
      'selected': instance.selected,
      'imgUrl': instance.imgUrl,
      'selectedColor': instance.selectedColor,
      'markerId': instance.markerId,
      'postId': instance.postId,
      'dataTime': RecordModel._toJsonTimestamp(instance.dataTime),
    };
