import 'package:dartz/dartz.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/features/other_profile/domain/entities/other_user/other_user_entity.dart';

abstract class OtherProfileRepository {
  /// Получить информацию о пользователе по ID
  Future<Either<Failure, OtherUserEntity>> getUserById(int userId);
}
