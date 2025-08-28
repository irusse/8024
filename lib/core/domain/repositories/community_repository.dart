import 'package:dartz/dartz.dart';

import '../../error/failures.dart';
import '../entities/event/participant_entity.dart';
import '../entities/user/user_entity.dart';

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
}
