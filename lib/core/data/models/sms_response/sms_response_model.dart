import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/sms_response/sms_response_entity.dart';

part 'sms_response_model.g.dart';

@JsonSerializable()
class SmsResponseModel {
  final String message;
  final String? code;

  const SmsResponseModel({
    required this.message,
    this.code,
  });

  factory SmsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SmsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SmsResponseModelToJson(this);

  SmsResponseEntity toEntity() => SmsResponseEntity(
        message: message,
        code: code,
      );

  factory SmsResponseModel.fromEntity(SmsResponseEntity entity) =>
      SmsResponseModel(
        message: entity.message,
        code: entity.code,
      );
}
