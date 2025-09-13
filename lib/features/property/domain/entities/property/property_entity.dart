import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/core/constants/default_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/themes/theme.dart';

part 'property_entity.freezed.dart';

@freezed
abstract class PropertyEntity with _$PropertyEntity {
  const factory PropertyEntity({
    required int id,
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    required String createdBy,
    required int createdById,
    required String verificationStatus,
    required int verificationCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<int> verifiedUserIds,
    required String photo,
  }) = _PropertyEntity;
}

extension PropertyEntityX on PropertyEntity {
  bool canVerify(int userId) =>
      createdById != userId &&
      verificationStatus != DefaultConstants.verified &&
      !verifiedUserIds.contains(userId);

  String buildVerificationStatusText() {
    final statusText =
        DefaultConstants.verificationStatus[verificationStatus] ?? 'Неизвестно';

    if (verificationStatus == DefaultConstants.unverified) {
      return '$statusText ($verificationCount из 2)';
    }
    return statusText;
  }

  Color verificationStatusColor(BuildContext context) {
    if (verificationStatus == DefaultConstants.unverified) {
      return CommonModeColors.orange;
    }
    return context.color.primary;
  }
}
