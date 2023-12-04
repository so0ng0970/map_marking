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
      'dataTime': RecordModel._toJsonTimestamp(instance.dataTime),
    };
