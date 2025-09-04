import 'package:dartz/dartz.dart';
import 'package:neighbours/core/error/failures.dart';

import '../entities/notification_list/notification_list_entity.dart';

abstract class NotificationRepository {
  /// Получить список уведомлений с пагинацией
  Future<Either<Failure, NotificationListEntity>> getNotifications({
    int page = 1,
    int limit = 10,
  });

  /// Получить количество непрочитанных уведомлений
  Future<Either<Failure, int>> getUnreadCount();
}
