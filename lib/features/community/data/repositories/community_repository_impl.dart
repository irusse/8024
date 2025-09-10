import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/features/community/data/datasources/community_remote_datasource.dart';
import 'package:neighbours/core/error/failures.dart';

import '../../../../core/domain/entities/event/participant_entity.dart';
import '../../../../core/domain/entities/user/user_entity.dart';
import '../../domain/entities/community/community_entity.dart';
import '../../domain/repositories/community_repository.dart';

@Singleton(as: CommunityRepository)
class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource _remoteDataSource;

  CommunityRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> createCommunity({
    required String communityName,
    required double userLatitude,
    required double userLongitude,
  }) async {
    final result = await _remoteDataSource.createCommunity(
      communityName: communityName,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
    );
    return result.fold(
        (failure) => Left(failure), (userModel) => Right(userModel.toEntity()));
  }

  @override
  Future<Either<Failure, UserEntity>> joinCommunity({
    required String communityCode,
    required double userLatitude,
    required double userLongitude,
  }) async {
    final result = await _remoteDataSource.joinCommunity(
      communityCode: communityCode,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
    );
    return result.fold(
        (failure) => Left(failure), (userModel) => Right(userModel.toEntity()));
  }

  @override
  Future<Either<Failure, List<ParticipantEntity>>> getCommunityParticipants(
      int communityId) async {
    final result =
        await _remoteDataSource.getCommunityParticipants(communityId);
    return result.fold(
      (failure) => Left(failure),
      (models) => Right(
        models.map((model) => model.toEntity()).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, CommunityEntity>> getCommunityById(String id) async {
    final result = await _remoteDataSource.getCommunityById(id);
    return result.fold(
      (failure) => Left(failure),
      (communityModel) => Right(communityModel.toEntity()),
    );
  }
}
