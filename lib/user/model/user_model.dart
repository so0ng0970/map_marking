// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  late String uid;
  late String email;
  late String photoUrl;
  late String userName;

  UserModel({
    required this.uid,
    required this.email,
    required this.photoUrl,
    required this.userName,
  });

    factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json); // 현재 인스턴스를 변환 ,json 으로 instance 변환 하는 것
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}


