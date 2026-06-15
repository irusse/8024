part of 'properties_cubit.dart';

@freezed
abstract class PropertiesState with _$PropertiesState {
  const factory PropertiesState({
    @Default({}) Map<int, PropertyEntity> properties,
    @Default(ApiState<void>.initial()) ApiState<void> createState,
    @Default(ApiState<void>.initial()) ApiState<void> updateState,
    @Default(ApiState<void>.initial()) ApiState<void> deleteState,
    @Default(ApiState<void>.initial()) ApiState<void> verifyState,
    @Default(ApiState<void>.initial()) ApiState<void> fetchState,
  }) = _PropertiesState;
}
