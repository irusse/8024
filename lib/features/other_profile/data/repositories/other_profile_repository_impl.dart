import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/features/other_profile/data/datasources/other_profile_remote_datasource.dart';
import 'package:neighbours/features/other_profile/domain/entities/other_user/other_user_entity.dart';
import 'package:neighbours/features/other_profile/domain/repositories/other_profile_repository.dart';

@Singleton(as: OtherProfileRepository)
class OtherProfileRepositoryImpl implements OtherProfileRepository {
  final OtherProfileRemoteDataSource _remoteDataSource;

  OtherProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, OtherUserEntity>> getUserById(int userId) async {
    final result = await _remoteDataSource.getUserById(userId);
    
    return result.fold(
      (failure) => Left(failure),
      (userModel) => Right(userModel.toEntity()),
    );
  }
}
