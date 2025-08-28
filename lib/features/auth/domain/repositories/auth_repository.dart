import 'package:dartz/dartz.dart';
import 'package:neighbours/core/error/failures.dart';

import '../../../../core/domain/entities/sms_response/sms_response_entity.dart';

abstract class AuthRepository {
  Future<void> logout();

  Future<Either<Failure,SmsResponseEntity>> phoneLogin(String phone);

  Future<Either<Failure,void>> verifySmsCode(String phone, String code);
}
