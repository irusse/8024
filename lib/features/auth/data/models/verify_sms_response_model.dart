import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/verify_sms_response_entity.dart';

part 'verify_sms_response_model.g.dart';

@JsonSerializable()
class VerifySmsResponseModel {
  final String accessToken;
  final String refreshToken;

  const VerifySmsResponseModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory VerifySmsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VerifySmsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifySmsResponseModelToJson(this);

  VerifySmsResponseEntity toEntity() => VerifySmsResponseEntity(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

  factory VerifySmsResponseModel.fromEntity(VerifySmsResponseEntity entity) =>
      VerifySmsResponseModel(
        accessToken: entity.accessToken,
        refreshToken: entity.refreshToken,
      );
}
