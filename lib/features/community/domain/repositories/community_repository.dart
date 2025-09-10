import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/event/participant_entity.dart';
import '../../../../core/domain/entities/user/user_entity.dart';
import '../entities/community/community_entity.dart';

abstract class CommunityRepository {
  Future<Either<Failure, UserEntity>> createCommunity({
    required String communityName,
    required double userLatitude,
    required double userLongitude,
  });

  Future<Either<Failure, UserEntity>> joinCommunity({
    required String communityCode,
    required double userLatitude,
    required double userLongitude,
  });

  Future<Either<Failure, List<ParticipantEntity>>> getCommunityParticipants(
      int communityId);

  Future<Either<Failure, CommunityEntity>> getCommunityById(String id);
}
