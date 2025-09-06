import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbours/core/domain/entities/event/event_category_entity.dart';
import 'package:neighbours/core/domain/entities/event/event_entity.dart';
import '../../error/failures.dart';

abstract class EventRepository {
  Future<Either<Failure, EventEntity>> createNotification({
    required String title,
    required double latitude,
    required double longitude,
    required int categoryId,
    required int communityId,
    required String description,
  });

  Future<Either<Failure, EventEntity>> createEvent({
    required String title,
    required int categoryId,
    required double latitude,
    required double longitude,
    required int communityId,
    required bool hasVoting,
    required String description,
    String? votingQuestion,
    List<String>? votingOptions,
    XFile? pickedImage,
    DateTime? eventDateTime,
  });

  Future<Either<Failure, List<EventEntity>>> fetchCommunityEvents({
    required String communityId,
    String? type,
    int? categoryId,
    int? page,
    int? limit,
  });

  Future<Either<Failure, EventEntity>> fetchEventById({
    required String eventId,
  });

  Future<Either<Failure, void>> deleteEvent({
    required String eventId,
  });

  Future<Either<Failure, List<EventCategoryEntity>>> fetchEventCategories();

  Future<Either<Failure, EventEntity>> joinEvent({
    required String eventId,
  });

  Future<Either<Failure, EventEntity>> leaveEvent({
    required String eventId,
  });

  Future<Either<Failure, List<EventEntity>>> fetchUserEvents({
    int? page,
    int? limit,
  });

  Future<Either<Failure, EventEntity>> updateNotification({
    required String id,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required int categoryId,
  });

  Future<Either<Failure, EventEntity>> updateEvent({
    required String id,
    required String title,
    required double latitude,
    required double longitude,
    required int categoryId,
    required DateTime eventDateTime,
    required String description,
    String? image,
    XFile? pickedImage,
    String? votingQuestion,
    List<String>? votingOptions,
    required bool hasVoting,
  });
}
