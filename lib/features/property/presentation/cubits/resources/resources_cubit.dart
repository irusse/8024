import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/features/property/domain/entities/resource/resource_entity.dart';
import 'package:neighbours/features/property/domain/repositories/resource_repository.dart';

import '../../../../../core/state/api_state.dart';

part 'resources_cubit.freezed.dart';

part 'resources_state.dart';

@LazySingleton()
class ResourcesCubit extends Cubit<ResourcesState> {
  final ResourceRepository _repository;

  ResourcesCubit(this._repository) : super(const ResourcesState());

  Future<void> fetchResourcesByPropertyId(int propertyId) async {
    _resetStates();
    emit(state.copyWith(fetchState: const ApiState.loading()));
    final result = await _repository.getResourcesByPropertyId(propertyId);
    result.fold(
      (failure) => emit(state.copyWith(
        fetchState: ApiState.failure(failure.message),
      )),
      (resources) => emit(state.copyWith(
        resources: resources,
        fetchState: const ApiState.success(null),
      )),
    );
  }

  Future<void> createResource({
    required String name,
    required String category,
    required int propertyId,
    XFile? photo,
  }) async {
    _resetStates();
    emit(state.copyWith(createState: const ApiState.loading()));
    final result = await _repository.createResource(
      name: name,
      category: category,
      propertyId: propertyId,
      photo: photo,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        createState: ApiState.failure(failure.message),
      )),
      (resource) => emit(state.copyWith(
        resources: [resource, ...state.resources],
        createState: const ApiState.success(null),
      )),
    );
  }

  Future<void> deleteResource(int id) async {
    _resetStates();
    final previousState = state;
    _removeResourceOptimistically(id);
    emit(state.copyWith(deleteState: const ApiState.loading()));
    final result = await _repository.deleteResource(id);
    result.fold(
      (failure) => emit(previousState.copyWith(
        deleteState: ApiState.failure(failure.message),
      )),
      (_) => emit(state.copyWith(
        deleteState: const ApiState.success(null),
      )),
    );
  }

  void _removeResourceOptimistically(int id) {
    final updatedResources = state.resources.where((r) => r.id != id).toList();
    emit(state.copyWith(resources: updatedResources));
  }

  Future<ResourceEntity?> updateResource({
    required int id,
    required String name,
    required String category,
    XFile? photo,
  }) async {
    _resetStates();
    emit(state.copyWith(updateState: const ApiState.loading()));
    final result = await _repository.updateResource(
      id: id,
      name: name,
      category: category,
      photo: photo,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(
          updateState: ApiState.failure(failure.message),
        ));
        return null;
      },
      (updated) => _handleResourceUpdated(updated),
    );
  }

  ResourceEntity _handleResourceUpdated(ResourceEntity updated) {
    final updatedResources =
        state.resources.map((r) => r.id == updated.id ? updated : r).toList();
    emit(state.copyWith(
      resources: updatedResources,
      updateState: const ApiState.success(null),
    ));
    return updated;
  }

  void _resetStates() {
    emit(state.copyWith(
        createState: const ApiState.initial(),
        fetchState: const ApiState.initial(),
        deleteState: const ApiState.initial(),
        updateState: const ApiState.initial()));
  }
}
