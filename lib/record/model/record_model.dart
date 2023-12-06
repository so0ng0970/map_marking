// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'record_model.g.dart';

@JsonSerializable()
class RecordModel {
  String title;
  String content;
  double markerLatitude;
  double markerLongitude;
  String selected;
  List<String>? imgUrl;
  int selectedColor;

  @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
  late DateTime dataTime;
  RecordModel({
    required this.title,
    required this.content,
    required this.markerLatitude,
    required this.markerLongitude,
    required this.selected,
    this.imgUrl,
    required this.selectedColor,
    required this.dataTime,
  });

  factory RecordModel.fromJson(Map<String, dynamic> json) =>
      _$RecordModelFromJson(json);

  get data => null;
  Map<String, dynamic> toJson() => _$RecordModelToJson(this);

  static DateTime _fromJsonTimestamp(Timestamp timestamp) => timestamp.toDate();

  static Timestamp _toJsonTimestamp(DateTime dateTime) =>
      Timestamp.fromDate(dateTime);
}
