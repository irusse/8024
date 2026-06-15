part of 'plan_b_cubit.dart';

@freezed
abstract class PlanBState with _$PlanBState {
  const factory PlanBState({
    @Default([]) List<PlanBMapEntity> items,
    @Default(ApiState<void>.initial()) ApiState<void> fetchState,
    @Default(ApiState<PlanBDetailsEntity>.initial())
    ApiState<PlanBDetailsEntity> detailsState,
    @Default(ApiState<void>.initial()) ApiState<void> listState,
    @Default(0) int total,
    @Default(0) int skip,
    @Default(false) bool hasMore,
  }) = _PlanBState;
}

