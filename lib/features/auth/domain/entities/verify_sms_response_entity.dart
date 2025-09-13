import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_sms_response_entity.freezed.dart';

@freezed
abstract class VerifySmsResponseEntity with _$VerifySmsResponseEntity {
  const factory VerifySmsResponseEntity({
    required String accessToken,
    required String refreshToken,
  }) = _VerifySmsResponseEntity;
} 