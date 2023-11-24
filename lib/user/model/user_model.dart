// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  late String? uid;
  late String? email;
  late String? photoUrl;
  late String? userName;

  UserModel({
    this.uid,
    this.email,
    this.photoUrl,
    this.userName,
  });
  bool get isEmpty {
    return uid == null && email == null && photoUrl == null && userName == null;
  }

  static UserModel get empty => UserModel();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json); // 현재 인스턴스를 변환 ,json 으로 instance 변환 하는 것
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
