import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_details/plan_b_parameter_option_entity.dart';

part 'plan_b_parameter_option_model.g.dart';

@JsonSerializable()
class PlanBParameterOptionModel {
  final int id;
  final String name;

  PlanBParameterOptionModel({
    required this.id,
    required this.name,
  });

  factory PlanBParameterOptionModel.fromJson(Map<String, dynamic> json) =>
      _$PlanBParameterOptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlanBParameterOptionModelToJson(this);

  PlanBParameterOptionEntity toEntity() => PlanBParameterOptionEntity(
        id: id,
        name: name,
      );
}
