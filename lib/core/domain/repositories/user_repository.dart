import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbours/core/domain/entities/user/user_entity.dart';
import 'package:neighbours/core/domain/entities/sms_response/sms_response_entity.dart';
import 'package:neighbours/core/domain/entities/profile_deletion/profile_deletion_entity.dart';
import 'package:neighbours/core/error/failures.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity>> fetchUser();

  Future<Either<Failure, UserEntity>> updateUser(UserEntity user,
      {XFile? avatarFile});

  Future<Either<Failure, SmsResponseEntity>> requestProfileDeletion();

  Future<Either<Failure, ProfileDeletionEntity>> confirmProfileDeletion(String code);

  Future<Either<Failure, String>> restoreProfile();
}
