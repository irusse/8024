import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_details/plan_b_parameter_option_entity.dart';

part 'plan_b_parameter_entity.freezed.dart';

@freezed
abstract class PlanBParameterEntity with _$PlanBParameterEntity {
  const factory PlanBParameterEntity({
    required int parameterId,
    required String name,
    required String fieldType,
    required bool isRequired,
    required int displayOrder,
    required List<PlanBParameterOptionEntity> options,
    String? value,
  }) = _PlanBParameterEntity;
}
