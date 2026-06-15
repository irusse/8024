import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/features/plan_b/data/models/plan_b_details/plan_b_parameter_option_model.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_details/plan_b_parameter_entity.dart';

part 'plan_b_parameter_model.g.dart';

@JsonSerializable()
class PlanBParameterModel {
  final int parameterId;
  final String name;
  final String fieldType;
  final bool isRequired;
  final int displayOrder;
  final List<PlanBParameterOptionModel> options;
  final String? value;

  PlanBParameterModel({
    required this.parameterId,
    required this.name,
    required this.fieldType,
    required this.isRequired,
    required this.displayOrder,
    required this.options,
    this.value,
  });

  factory PlanBParameterModel.fromJson(Map<String, dynamic> json) =>
      _$PlanBParameterModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlanBParameterModelToJson(this);

  PlanBParameterEntity toEntity() => PlanBParameterEntity(
        parameterId: parameterId,
        name: name,
        fieldType: fieldType,
        isRequired: isRequired,
        displayOrder: displayOrder,
        options: options.map((o) => o.toEntity()).toList(),
        value: value,
      );
}
