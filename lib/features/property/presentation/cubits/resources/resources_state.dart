part of 'resources_cubit.dart';

@freezed
abstract class ResourcesState with _$ResourcesState {
  const factory ResourcesState({
    @Default([]) List<ResourceEntity> resources,
    @Default(ApiState<void>.initial()) ApiState<void> createState,
    @Default(ApiState<void>.initial()) ApiState<void> deleteState,
    @Default(ApiState<void>.initial()) ApiState<void> updateState,
    @Default(ApiState<void>.initial()) ApiState<void> fetchState,
  }) = _ResourcesState;
}

extension ResourcesStateX on ResourcesState {
  bool get hasError =>
      createState.isFailure ||
      updateState.isFailure ||
      deleteState.isFailure ||
      fetchState.isFailure;

  String? get error =>
      createState.error ??
      updateState.error ??
      deleteState.error ??
      fetchState.error;
}
