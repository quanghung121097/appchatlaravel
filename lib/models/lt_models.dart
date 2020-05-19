import 'package:json_annotation/json_annotation.dart';

part 'lt_models.g.dart';

/// https://flutter.io/docs/development/data-and-backend/json
/// One-time code generation: flutter packages pub run build_runner build --delete-conflicting-outputs
/// Generating code continuously: flutter packages pub run build_runner watch
///
@JsonSerializable()
class ResponseModel {
  @JsonKey(name: 'code')
  dynamic code;

  @JsonKey(name: 'message')
  String message;

  @JsonKey(name: 'data')
  dynamic data;

//  @JsonKey(name: 'token')
//  AuthModel auth;

  ResponseModel({this.code, this.message, this.data});

  factory ResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseModelToJson(this);

  bool get isSucceed => (this.code == 200);
}
