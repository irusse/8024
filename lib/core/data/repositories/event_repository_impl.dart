import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbours/core/data/datasources/event_remote_datasource.dart';
import 'package:neighbours/core/error/failures.dart';
import '../../domain/entities/event/event_category_entity.dart';
import '../../domain/entities/event/event_entity.dart';
import '../../domain/repositories/event_repository.dart';

@Singleton(as: EventRepository)
class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource _remoteDataSource;

  EventRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, EventEntity>> createNotification({
    required String title,
    required double latitude,
    required double longitude,
    required int categoryId,
    required int communityId,
    required String description,
  }) async {
    final result = await _remoteDataSource.createNotification(
      title: title,
      latitude: latitude,
      longitude: longitude,
      categoryId: categoryId,
      communityId: communityId,
      description: description,
    );
    return result.fold(
        (error) => Left(error), (model) => Right(model.toEntity()));
  }

  @override
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
  }) async {
    final result = await _remoteDataSource.createEvent(
      title: title,
      description: description,
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
      communityId: communityId,
      hasVoting: hasVoting,
      votingQuestion: votingQuestion,
      votingOptions: votingOptions,
      pickedImage: pickedImage,
      eventDateTime: eventDateTime,
    );
    return result.fold(
        (error) => Left(error), (model) => Right(model.toEntity()));
  }

  @override
  Future<Either<Failure, List<EventEntity>>> fetchCommunityEvents({
    required String communityId,
    String? type,
    int? categoryId,
    int? page,
    int? limit,
  }) async {
    final result = await _remoteDataSource.fetchCommunityEvents(
      communityId: communityId,
      type: type,
      categoryId: categoryId,
      page: page,
      limit: limit,
    );
    return result.fold((failure) => Left(failure),
        (models) => Right(models.map((m) => m.toEntity()).toList()));
  }

  @override
  Future<Either<Failure, void>> deleteEvent({
    required String eventId,
  }) async {
    return await _remoteDataSource.deleteEvent(eventId: eventId);
  }

  @override
  Future<Either<Failure, List<EventCategoryEntity>>>
      fetchEventCategories() async {
    final result = await _remoteDataSource.fetchEventCategories();
    return result.fold(
      (failure) => Left(failure),
      (models) => Right(models.map((model) => model.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, EventEntity>> joinEvent({
    required String eventId,
  }) async {
    final result = await _remoteDataSource.joinEvent(eventId: eventId);
    return result.fold(
        (error) => Left(error), (model) => Right(model.toEntity()));
  }

  @override
  Future<Either<Failure, EventEntity>> leaveEvent({
    required String eventId,
  }) async {
    final result = await _remoteDataSource.leaveEvent(eventId: eventId);
    return result.fold(
        (error) => Left(error), (model) => Right(model.toEntity()));
  }

  @override
  Future<Either<Failure, List<EventEntity>>> fetchUserEvents({
    int? page,
    int? limit,
  }) async {
    final result = await _remoteDataSource.fetchUserEvents(
      page: page,
      limit: limit,
    );
    return result.fold(
      (failure) => Left(failure),
      (models) => Right(models.map((model) => model.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, EventEntity>> updateNotification({
    required String id,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required int categoryId,
  }) async {
    final result = await _remoteDataSource.updateNotification(
      id: id,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      categoryId: categoryId,
    );
    return result.fold(
        (error) => Left(error), (model) => Right(model.toEntity()));
  }

  @override
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
  }) async {
    final result = await _remoteDataSource.updateEvent(
      id: id,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      categoryId: categoryId,
      eventDateTime: eventDateTime,
      image: image,
      pickedImage: pickedImage,
      votingQuestion: votingQuestion,
      votingOptions: votingOptions,
      hasVoting: hasVoting,
    );
    return result.fold(
        (error) => Left(error), (model) => Right(model.toEntity()));
  }
}
