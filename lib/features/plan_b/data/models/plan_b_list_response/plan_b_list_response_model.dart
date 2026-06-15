import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neighbours/features/plan_b/data/models/plan_b_map/plan_b_map_model.dart';

part 'plan_b_list_response_model.g.dart';

@JsonSerializable()
class PlanBListResponseModel {
  final List<PlanBMapModel> items;
  final int total;
  final int skip;
  final int take;

  PlanBListResponseModel({
    required this.items,
    required this.total,
    required this.skip,
    required this.take,
  });

  factory PlanBListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PlanBListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlanBListResponseModelToJson(this);
}
