import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_b_parameter_option_entity.freezed.dart';

@freezed
abstract class PlanBParameterOptionEntity with _$PlanBParameterOptionEntity {
  const factory PlanBParameterOptionEntity({
    required int id,
    required String name,
  }) = _PlanBParameterOptionEntity;
}
