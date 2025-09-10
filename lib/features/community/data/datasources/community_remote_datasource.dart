import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/data/models/event/participant_model.dart';
import 'package:neighbours/core/network/network_handler.dart';
import '../../../../core/data/models/user/user_model.dart';
import '../models/communtiy/community_model.dart';

abstract class CommunityRemoteDataSource {
  Future<Either<Failure, UserModel>> createCommunity({
    required String communityName,
    required double userLatitude,
    required double userLongitude,
  });

  Future<Either<Failure, UserModel>> joinCommunity({
    required String communityCode,
    required double userLatitude,
    required double userLongitude,
  });

  Future<Either<Failure, List<ParticipantModel>>> getCommunityParticipants(
      int communityId);

  Future<Either<Failure, CommunityModel>> getCommunityById(String id);
}

@Singleton(as: CommunityRemoteDataSource)
class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final Dio _dio;

  CommunityRemoteDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, UserModel>> createCommunity({
    required String communityName,
    required double userLatitude,
    required double userLongitude,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final data = {
        'communityName': communityName.trim(),
        'userLatitude': userLatitude,
        'communityLatitude': userLatitude,
        'communityLongitude': userLongitude,
        'userLongitude': userLongitude,
      };

      final response = await _dio.post(
        '/users/registration/step-four',
        data: data,
      );

      return UserModel.fromJson(response.data['user']);
    });
  }

  @override
  Future<Either<Failure, UserModel>> joinCommunity({
    required String communityCode,
    required double userLatitude,
    required double userLongitude,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final data = {
        'communityCode': communityCode.trim(),
        'userLatitude': userLatitude,
        'communityLatitude': userLatitude,
        'communityLongitude': userLongitude,
        'userLongitude': userLongitude,
      };

      final response = await _dio.post(
        '/users/registration/step-four',
        data: data,
      );

      return UserModel.fromJson(response.data['user']);
    });
  }

  @override
  Future<Either<Failure, List<ParticipantModel>>> getCommunityParticipants(
      int communityId) {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get(
        '/users/communities/$communityId/users',
      );
      final List<dynamic> data = response.data as List<dynamic>;

      final participants = data
          .map(
              (json) => ParticipantModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return participants;
    });
  }

  @override
  Future<Either<Failure, CommunityModel>> getCommunityById(String id) {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get('/api/communities/$id');
      return CommunityModel.fromJson(response.data);
    });
  }
}
