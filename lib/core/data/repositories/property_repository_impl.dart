import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/data/datasources/property_remote_datasource.dart';
import 'package:neighbours/core/domain/entities/property/property_entity.dart';
import 'package:neighbours/core/domain/entities/user_verified_property/user_verified_property_entity.dart';
import 'package:neighbours/core/domain/repositories/property_repository.dart';
import 'package:neighbours/core/error/failures.dart';

@Singleton(as: PropertyRepository)
class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDataSource _remoteDataSource;

  PropertyRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, PropertyEntity>> add({
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    required double userLatitude,
    required double userLongitude,
    XFile? photo,
    bool isFirstProperty = false,
  }) async {
    final result = isFirstProperty
        ? await _remoteDataSource.addFirst(
            name: name,
            category: category,
            latitude: latitude,
            longitude: longitude,
            userLatitude: userLatitude,
            userLongitude: userLongitude,
            photo: photo,
          )
        : await _remoteDataSource.addRegular(
            name: name,
            category: category,
            latitude: latitude,
            longitude: longitude,
            userLatitude: userLatitude,
            userLongitude: userLongitude,
            photo: photo,
          );

    return result.fold(
      (failure) => Left(failure),
      (property) => Right(property.toEntity()),
    );
  }

  @override
  Future<Map<int, PropertyEntity>> fetchMyProperties() async {
    final modelsMap = await _remoteDataSource.fetchMyProperties();

    return modelsMap.map((key, value) => MapEntry(key, value.toEntity()));
  }

  @override
  Future<Either<Failure, void>> deleteProperty(int propertyId) async {
    return await _remoteDataSource.deleteProperty(propertyId);
  }

  @override
  Future<PropertyEntity> updateProperty({
    required int id,
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    XFile? photo,
  }) async {
    final propertyModel = await _remoteDataSource.updateProperty(
      id: id,
      name: name,
      category: category,
      latitude: latitude,
      longitude: longitude,
      photo: photo,
    );
    return propertyModel.toEntity();
  }

  @override
  Future<Map<int, PropertyEntity>> fetchPropertiesByCommunityId(
      String communityId) async {
    final modelsMap =
        await _remoteDataSource.fetchPropertiesByCommunityId(communityId);
    return modelsMap.map((key, value) => MapEntry(key, value.toEntity()));
  }

  @override
  Future<Map<int, PropertyEntity>> fetchUnverifiedOthersProperties({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    final modelsMap = await _remoteDataSource.fetchUnverifiedOthersProperties(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
    return modelsMap.map((key, value) => MapEntry(key, value.toEntity()));
  }

  @override
  Future<Either<Failure, PropertyEntity>> verifyProperty({
    required int propertyId,
    required double userLatitude,
    required double userLongitude,
  }) async {
    final result = await _remoteDataSource.verifyProperty(
      propertyId: propertyId,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
    );

    return result.fold(
      (failure) => Left(failure),
      (propertyModel) => Right(propertyModel.toEntity()),
    );
  }

  @override
  Future<Either<Failure, List<UserVerifiedPropertyEntity>>>
      getUserVerifications() async {
    final result = await _remoteDataSource.getUserVerifications();

    return result.fold(
      (failure) => Left(failure),
      (modelsList) =>
          Right(modelsList.map((model) => model.toEntity()).toList()),
    );
  }
}
