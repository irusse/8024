import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';

import '../../domain/entities/notification_list/notification_list_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

@Singleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, NotificationListEntity>> getNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    final result = await _remoteDataSource.getNotifications(
      page: page,
      limit: limit,
    );

    return result.fold(
      (failure) => Left(failure),
      (notificationListModel) => Right(
        NotificationListEntity(
          data: notificationListModel.data
              .map((model) => model.toEntity())
              .toList(),
          unreadCount: notificationListModel.unreadCount,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    return await _remoteDataSource.getUnreadCount();
  }
}
