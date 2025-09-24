import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/property/domain/entities/light_property/light_property_entity.dart';
import 'package:neighbours/features/property/domain/repositories/property_repository.dart';

part 'other_properties_state.dart';

part 'other_properties_cubit.freezed.dart';

@Injectable()
class OtherPropertiesCubit extends Cubit<OtherPropertiesState> {
  final PropertyRepository _repository;

  OtherPropertiesCubit(this._repository) : super(const OtherPropertiesState());

  /// Получить список объектов пользователя
  Future<void> fetchUserProperties(int userId) async {
    emit(state.copyWith(fetchPropertiesState: const ApiState.loading()));

    final result = await _repository.getUserProperties(userId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          fetchPropertiesState: ApiState.failure(failure.message),
        ));
      },
      (properties) {
        emit(state.copyWith(
          properties: properties,
          fetchPropertiesState: const ApiState.success(null),
        ));
      },
    );
  }
}
