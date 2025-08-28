import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/constants/default_constants.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/network/network_handler.dart';

import '../models/event/event_category_model.dart';
import '../models/event/event_model.dart';

abstract class EventRemoteDataSource {
  Future<Either<Failure, EventModel>> createNotification({
    required String title,
    required double latitude,
    required double longitude,
    required int categoryId,
    required int communityId,
    required String description,
  });

  Future<Either<Failure, EventModel>> createEvent({
    required String title,
    required int categoryId,
    required double latitude,
    required double longitude,
    required int communityId,
    required bool hasVoting,
    String? votingQuestion,
    List<String>? votingOptions,
    String? description,
    XFile? pickedImage,
    DateTime? eventDateTime,
  });

  Future<Either<Failure, List<EventModel>>> fetchCommunityEvents({
    required String communityId,
    String? type,
    int? categoryId,
    int? page,
    int? limit,
  });

  Future<Either<Failure, void>> deleteEvent({
    required String eventId,
  });

  Future<Either<Failure, List<EventCategoryModel>>> fetchEventCategories();

  Future<Either<Failure, EventModel>> joinEvent({
    required String eventId,
  });

  Future<Either<Failure, EventModel>> leaveEvent({
    required String eventId,
  });

  Future<Either<Failure, List<EventModel>>> fetchUserEvents({
    int? page,
    int? limit,
  });

  Future<Either<Failure, EventModel>> updateNotification({
    required String id,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required int categoryId,
  });

  Future<Either<Failure, EventModel>> updateEvent({
    required String id,
    required String title,
    required double latitude,
    required double longitude,
    required int categoryId,
    required DateTime eventDateTime,
    required String description,
    required bool hasVoting,
    String? image,
    XFile? pickedImage,
    String? votingQuestion,
    List<String>? votingOptions,
  });
}

@Singleton(as: EventRemoteDataSource)
class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final Dio _dio;

  EventRemoteDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, EventModel>> createNotification({
    required String title,
    required double latitude,
    required double longitude,
    required int categoryId,
    required int communityId,
    required String description,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final data = {
        'title': title,
        'latitude': latitude,
        'longitude': longitude,
        'categoryId': categoryId,
        'communityId': communityId,
        'type': DefaultConstants.notification,
        'description': description,
      };
      final response = await _dio.post('/events', data: data);
      return EventModel.fromJson(response.data);
    });
  }

  @override
  Future<Either<Failure, EventModel>> createEvent({
    required String title,
    required int categoryId,
    required double latitude,
    required double longitude,
    required int communityId,
    required bool hasVoting,
    String? votingQuestion,
    List<String>? votingOptions,
    String? description,
    XFile? pickedImage,
    DateTime? eventDateTime,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final data = FormData.fromMap({
        'title': title,
        'categoryId': categoryId,
        'latitude': latitude,
        'longitude': longitude,
        'communityId': communityId,
        'hasVoting': hasVoting.toString(),
        'type': DefaultConstants.event,
        'description': description,
        if (votingQuestion != null) 'votingQuestion': votingQuestion,
        if (votingOptions != null) 'votingOptions': votingOptions.join(','),
        if (eventDateTime != null) 'eventDateTime': eventDateTime.toUtc(),
        if (pickedImage != null)
          'image': await MultipartFile.fromFile(
            pickedImage.path,
            filename: pickedImage.name,
          ),
      });

      final response = await _dio.post(
        '/events',
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );

      return EventModel.fromJson(response.data);
    });
  }

  @override
  Future<Either<Failure, List<EventModel>>> fetchCommunityEvents({
    required String communityId,
    String? type,
    int? categoryId,
    int? page,
    int? limit,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final queryParams = <String, dynamic>{
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (type != null) 'type': type,
        if (categoryId != null) 'categoryId': categoryId,
      };

      final response = await _dio.get('/events/community/$communityId',
          queryParameters: queryParams);
      return EventModel.fromJsonList(response.data);
    });
  }

  @override
  Future<Either<Failure, void>> deleteEvent({
    required String eventId,
  }) async {
    return NetworkHandler.handleRequest(() async {
      await _dio.delete('/events/$eventId');
    });
  }

  @override
  Future<Either<Failure, List<EventCategoryModel>>>
      fetchEventCategories() async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get('/event-categories');
      final List<dynamic> data = response.data;
      return data.map((json) => EventCategoryModel.fromJson(json)).toList();
    });
  }

  @override
  Future<Either<Failure, EventModel>> joinEvent({
    required String eventId,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.post('/events/$eventId/join');
      return EventModel.fromJson(response.data);
    });
  }

  @override
  Future<Either<Failure, EventModel>> leaveEvent({
    required String eventId,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.post('/events/$eventId/leave');
      return EventModel.fromJson(response.data);
    });
  }

  @override
  Future<Either<Failure, List<EventModel>>> fetchUserEvents({
    int? page,
    int? limit,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final queryParams = <String, dynamic>{
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      };

      final response =
          await _dio.get('/users/events', queryParameters: queryParams);
      return EventModel.fromJsonList(response.data);
    });
  }

  @override
  Future<Either<Failure, EventModel>> updateNotification({
    required String id,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required int categoryId,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final data = {
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'categoryId': categoryId,
      };
      final response = await _dio.patch('/events/$id', data: data);
      return EventModel.fromJson(response.data);
    });
  }

  @override
  Future<Either<Failure, EventModel>> updateEvent({
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
    return NetworkHandler.handleRequest(() async {
      final data = FormData.fromMap({
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'categoryId': categoryId,
        'eventDateTime': eventDateTime.toUtc(),
        if (votingQuestion != null) 'votingQuestion': votingQuestion,
        if (votingOptions != null) 'votingOptions': votingOptions.join(','),
        if (pickedImage != null)
          'image': await MultipartFile.fromFile(pickedImage.path,
              filename: pickedImage.name),
      });

      final response = await _dio.patch(
        '/events/$id',
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );

      return EventModel.fromJson(response.data);
    });
  }
}
