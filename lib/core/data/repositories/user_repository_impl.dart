import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/data/datasources/user_remote_datasource.dart';
import 'package:neighbours/core/data/models/user/user_model.dart';
import 'package:neighbours/core/domain/entities/user/user_entity.dart';
import 'package:neighbours/core/domain/entities/sms_response/sms_response_entity.dart';
import 'package:neighbours/core/domain/entities/profile_deletion/profile_deletion_entity.dart';
import 'package:neighbours/core/domain/repositories/user_repository.dart';
import 'package:neighbours/core/error/failures.dart';

@Singleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remote;

  UserRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, UserEntity>> fetchUser() async {
    final result = await _remote.fetchUser();

    return result.fold(
        (failure) => Left(failure), (userModel) => Right(userModel.toEntity()));
  }
  @override
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user,
      {XFile? avatarFile}) async {
    final userModel = UserModel.fromEntity(user);
    final result = await _remote.updateUser(userModel, avatarFile: avatarFile);

    return result.fold(
      (failure) => Left(failure),
      (userModel) => Right(userModel.toEntity()),
    );
  }

  @override
  Future<Either<Failure, SmsResponseEntity>> requestUserDeletion() async {
    final result = await _remote.requestProfileDeletion();

    return result.fold(
      (failure) => Left(failure),
      (smsResponseModel) => Right(smsResponseModel.toEntity()),
    );
  }

  @override
  Future<Either<Failure, ProfileDeletionEntity>> confirmUserDeletion(
      String code) async {
    final result = await _remote.confirmProfileDeletion(code);

    return result.fold(
      (failure) => Left(failure),
      (profileDeletionModel) => Right(profileDeletionModel.toEntity()),
    );
  }

  @override
  Future<Either<Failure, UserEntity>> submitUser({
    required String name,
    required String surname,
    required String email,
    XFile? image,
  }) async {
    final result = await _remote.submitProfile(
      name: name,
      surname: surname,
      email: email,
      image: image,
    );

    return result.fold(
      (failure) => Left(failure),
      (userModel) => Right(userModel.toEntity()),
    );
  }

  @override
  Future<Either<Failure, String>> restoreUser() async {
    final result = await _remote.restoreProfile();

    return result.fold(
      (failure) => Left(failure),
      (message) => Right(message),
    );
  }
}
