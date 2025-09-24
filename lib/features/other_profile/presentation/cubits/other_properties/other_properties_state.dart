part of 'other_properties_cubit.dart';

@freezed
abstract class OtherPropertiesState with _$OtherPropertiesState {
  const factory OtherPropertiesState({
    @Default([]) List<LightPropertyEntity> properties,
    @Default(ApiState.initial()) ApiState<void> fetchPropertiesState,
  }) = _OtherPropertiesState;
}
