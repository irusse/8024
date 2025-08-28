import 'package:freezed_annotation/freezed_annotation.dart';

part 'sms_response_entity.freezed.dart';

@freezed
class SmsResponseEntity with _$SmsResponseEntity {
  const factory SmsResponseEntity({
    required String message,
    String? code,
  }) = _SmsResponseEntity;
}
