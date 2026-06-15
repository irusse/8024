import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/network/network_handler.dart';

import '../models/notification_list/notification_list_model.dart';

abstract class NotificationRemoteDataSource {
  /// Получить список уведомлений с пагинацией
  Future<Either<Failure, NotificationListModel>> getNotifications({
    int page = 1,
    int limit = 10,
  });

  /// Получить количество непрочитанных уведомлений
  Future<Either<Failure, int>> getUnreadCount();

  /// Удалить все уведомления
  Future<Either<Failure, void>> deleteAllNotifications();

  /// Отметить уведомление как прочитанное
  Future<Either<Failure, void>> markAsRead(int notificationId);
}

@Singleton(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, NotificationListModel>> getNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return NotificationListModel.fromJson(response.data);
    });
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get('/notifications/unread-count');
      return response.data['count'] as int;
    });
  }

  @override
  Future<Either<Failure, void>> deleteAllNotifications() async {
    return NetworkHandler.handleRequest(() async {
      await _dio.delete('/notifications');
    });
  }

  @override
  Future<Either<Failure, void>> markAsRead(int notificationId) async {
    return NetworkHandler.handleRequest(() async {
      await _dio.patch('/notifications/$notificationId/read');
    });
  }
}
