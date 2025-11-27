import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_b_entity.freezed.dart';

@freezed
abstract class PlanBEntity with _$PlanBEntity {
  const factory PlanBEntity({
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
    required List<String> photos,
  }) = _PlanBEntity;
}
