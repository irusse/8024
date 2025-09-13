import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/property/domain/entities/property/property_entity.dart';
import 'package:neighbours/features/property/domain/repositories/property_repository.dart';

part 'properties_cubit.freezed.dart';

part 'properties_state.dart';

@singleton
class PropertiesCubit extends Cubit<PropertiesState> {
  final PropertyRepository _propertyRepository;

  PropertiesCubit(this._propertyRepository) : super(const PropertiesState());

  Future<void> fetchMyProperties() async {
    _resetStates();
    emit(state.copyWith(fetchState: const ApiState.loading()));
    try {
      final propertiesMap = await _propertyRepository.fetchMyProperties();
      emit(state.copyWith(
        properties: propertiesMap,
        fetchState: const ApiState.success(null),
      ));
    } catch (e) {
      emit(state.copyWith(fetchState: ApiState.failure(e.toString())));
    }
  }

  Future<void> fetchPropertiesByCommunityId(String communityId) async {
    _resetStates();
    emit(state.copyWith(fetchState: const ApiState.loading()));
    try {
      final propertiesMap =
          await _propertyRepository.fetchPropertiesByCommunityId(communityId);
      emit(state.copyWith(
        properties: propertiesMap,
        fetchState: const ApiState.success(null),
      ));
    } catch (e) {
      emit(state.copyWith(fetchState: ApiState.failure(e.toString())));
    }
  }

  Future<void> deleteProperty(int propertyId) async {
    _resetStates();
    emit(state.copyWith(deleteState: const ApiState.loading()));
    final result = await _propertyRepository.deleteProperty(propertyId);

    result.fold(
      (failure) {
        emit(state.copyWith(deleteState: ApiState.failure(failure.message)));
      },
      (_) {
        final updatedProperties =
            Map<int, PropertyEntity>.from(state.properties)..remove(propertyId);
        emit(state.copyWith(
          properties: updatedProperties,
          deleteState: const ApiState.success(null),
        ));
      },
    );
  }

  Future<PropertyEntity?> addProperty({
    required bool isFirstProperty,
    required String name,
    required String selectedType,
    XFile? pickedImage,
    required double userLatitude,
    required double latitude,
    required double longitude,
    required double userLongitude,
  }) async {
    _resetStates();
    emit(state.copyWith(createState: const ApiState.loading()));
    final result = await _propertyRepository.add(
      name: name,
      category: selectedType,
      latitude: latitude,
      longitude: longitude,
      photo: pickedImage,
      isFirstProperty: isFirstProperty,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(createState: ApiState.failure(failure.message)));
        return null;
      },
      (property) {
        final updated = Map<int, PropertyEntity>.from(state.properties)
          ..[property.id] = property;
        emit(state.copyWith(
          properties: updated,
          createState: const ApiState.success(null),
        ));
        return property;
      },
    );
  }

  Future<PropertyEntity?> updateProperty({
    required int id,
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    XFile? photo,
  }) async {
    _resetStates();
    emit(state.copyWith(updateState: const ApiState.loading()));
    try {
      final updatedProperty = await _propertyRepository.updateProperty(
        id: id,
        name: name,
        category: category,
        latitude: latitude,
        longitude: longitude,
        photo: photo,
      );

      final updatedMap = Map<int, PropertyEntity>.from(state.properties)
        ..[id] = updatedProperty;

      emit(state.copyWith(
        properties: updatedMap,
        updateState: const ApiState.success(null),
      ));

      return updatedProperty;
    } catch (e) {
      emit(state.copyWith(updateState: ApiState.failure(e.toString())));
      return null;
    }
  }

  PropertyEntity? getUserProperty(int userId) {
    return state.properties.values.firstWhereOrNull(
      (prop) => prop.createdById == userId,
    );
  }

  Future<void> fetchUnverifiedOthersProperties({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    _resetStates();
    emit(state.copyWith(fetchState: const ApiState.loading()));
    try {
      final newPropertiesMap =
          await _propertyRepository.fetchUnverifiedOthersProperties(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      final updatedProperties = Map<int, PropertyEntity>.from(state.properties)
        ..addAll(newPropertiesMap);

      emit(state.copyWith(
        properties: updatedProperties,
        fetchState: const ApiState.success(null),
      ));
    } catch (e) {
      emit(state.copyWith(fetchState: ApiState.failure(e.toString())));
    }
  }

  void onLogout() {
    emit(state.copyWith(properties: {}));
  }

  void _resetStates() {
    emit(state.copyWith(
        createState: const ApiState.initial(),
        fetchState: const ApiState.initial(),
        deleteState: const ApiState.initial(),
        updateState: const ApiState.initial(),
        verifyState: const ApiState.initial()));
  }

  Future<PropertyEntity?> verifyProperty({
    required int propertyId,
    required double userLatitude,
    required double userLongitude,
  }) async {
    _resetStates();
    emit(state.copyWith(verifyState: const ApiState.loading()));

    final result = await _propertyRepository.verifyProperty(
      propertyId: propertyId,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(verifyState: ApiState.failure(failure.message)));
        return null;
      },
      (verifiedProperty) {
        final updatedProperties =
            Map<int, PropertyEntity>.from(state.properties)
              ..[propertyId] = verifiedProperty;
        emit(state.copyWith(
          properties: updatedProperties,
          verifyState: const ApiState.success(null),
        ));
        return verifiedProperty;
      },
    );
  }

  Future<PropertyEntity?> getPropertyById(int id) async {
    _resetStates();
    emit(state.copyWith(fetchState: const ApiState.loading()));

    final result = await _propertyRepository.getPropertyById(id);

    return result.fold(
      (failure) {
        emit(state.copyWith(fetchState: ApiState.failure(failure.message)));
        return null;
      },
      (property) {
        final updatedProperties =
            Map<int, PropertyEntity>.from(state.properties)..[id] = property;

        emit(state.copyWith(
          properties: updatedProperties,
          fetchState: const ApiState.success(null),
        ));
        return property;
      },
    );
  }
}
