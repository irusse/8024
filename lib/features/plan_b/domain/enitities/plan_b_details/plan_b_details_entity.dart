import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_details/plan_b_category_short_entity.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_details/plan_b_parameter_entity.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_details/plan_b_photo_entity.dart';

part 'plan_b_details_entity.freezed.dart';

@freezed
abstract class PlanBDetailsEntity with _$PlanBDetailsEntity {
  const factory PlanBDetailsEntity({
    required int id,
    required String name,
    String? description,
    String? address,
    String? autonomyNotes,
    String? financeInfo,
    required int categoryId,
    double? latitude,
    double? longitude,
    double? price,
    required String status,
    required int createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required PlanBCategoryShortEntity category,
    required List<PlanBPhotoEntity> photos,
    required List<PlanBParameterEntity> parameters,
  }) = _PlanBDetailsEntity;
}
