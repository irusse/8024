part of 'plan_b_cubit.dart';

@freezed
abstract class PlanBState with _$PlanBState {
  const factory PlanBState({
    @Default([]) List<PlanBMapEntity> items,
    @Default(ApiState<void>.initial()) ApiState<void> fetchState,
    @Default(ApiState<PlanBDetailsEntity>.initial())
    ApiState<PlanBDetailsEntity> detailsState,
  }) = _PlanBState;
}

