import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/network/network_handler.dart';
import 'package:neighbours/features/property/data/models/property/property_model.dart';
import 'package:neighbours/features/property/data/models/light_property/light_property_model.dart';
import 'package:neighbours/features/property/data/models/user_verified_property/user_verified_property_model.dart';

abstract class PropertyRemoteDataSource {
  Future<Either<Failure, PropertyModel>> addFirst({
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    required double userLatitude,
    required double userLongitude,
    XFile? photo,
  });

  Future<Either<Failure, PropertyModel>> addRegular({
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    required double userLatitude,
    required double userLongitude,
    XFile? photo,
  });

  Future<Map<int, PropertyModel>> fetchMyProperties();

  Future<Map<int, PropertyModel>> fetchPropertiesByCommunityId(String id);

  Future<Either<Failure, void>> deleteProperty(int propertyId);

  Future<PropertyModel> updateProperty({
    required int id,
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    XFile? photo,
  });

  Future<Map<int, PropertyModel>> fetchUnverifiedOthersProperties({
    required double latitude,
    required double longitude,
    required double radius,
  });

  Future<Either<Failure, PropertyModel>> verifyProperty({
    required int propertyId,
    required double userLatitude,
    required double userLongitude,
  });

  Future<Either<Failure, List<UserVerifiedPropertyModel>>>
      getUserVerifications();

  Future<Either<Failure, PropertyModel>> getPropertyById(int id);

  /// Получить список объектов пользователя
  Future<Either<Failure, List<LightPropertyModel>>> getUserProperties(int userId);
}

@Singleton(as: PropertyRemoteDataSource)
class PropertyRemoteDataSourceImpl implements PropertyRemoteDataSource {
  final Dio _dio;

  PropertyRemoteDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, PropertyModel>> addFirst({
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    required double userLatitude,
    required double userLongitude,
    XFile? photo,
  }) {
    return _addProperty(
      endpoint: '/users/registration/step-three',
      name: name,
      category: category,
      latitude: latitude,
      longitude: longitude,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      photo: photo,
    );
  }

  @override
  Future<Either<Failure, PropertyModel>> addRegular({
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    required double userLatitude,
    required double userLongitude,
    XFile? photo,
  }) {
    return _addProperty(
      endpoint: '/properties/my',
      name: name,
      category: category,
      latitude: latitude,
      longitude: longitude,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      photo: photo,
    );
  }

  Future<Either<Failure, PropertyModel>> _addProperty({
    required String endpoint,
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    required double userLatitude,
    required double userLongitude,
    XFile? photo,
  }) async {
    final formData = FormData.fromMap({
      'name': name.trim(),
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
      if (photo != null)
        'photo': await MultipartFile.fromFile(photo.path, filename: photo.name),
    });

    return NetworkHandler.handleRequest(() async {
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return PropertyModel.fromJson(response.data);
    });
  }

  @override
  Future<Map<int, PropertyModel>> fetchMyProperties() async {
    final response = await _dio.get('/properties/my');
    final rawData = response.data as List;

    final propertiesList = rawData
        .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return {for (var property in propertiesList) property.id: property};
  }

  @override
  Future<Either<Failure, void>> deleteProperty(int propertyId) async {
    return NetworkHandler.handleRequest(() async {
      await _dio.delete('/properties/my/$propertyId');
    });
  }

  @override
  Future<PropertyModel> updateProperty({
    required int id,
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    XFile? photo,
  }) async {
    final formData = FormData.fromMap({
      'name': name.trim(),
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'photo': photo != null
          ? await MultipartFile.fromFile(photo.path, filename: photo.name)
          : null,
    });
    try {
      final response = await _dio.patch(
        '/properties/my/$id',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return PropertyModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Ошибка при обновлении недвижимости');
    }
  }

  @override
  Future<Map<int, PropertyModel>> fetchPropertiesByCommunityId(
      String communityId) async {
    final response = await _dio.get(
      '/properties/community',
      queryParameters: {'communityId': communityId},
    );
    final rawData = response.data as List;
    final propertiesList = rawData
        .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return {for (var property in propertiesList) property.id: property};
  }

  @override
  Future<Map<int, PropertyModel>> fetchUnverifiedOthersProperties({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    final response = await _dio.get(
      '/properties/unverified-others',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      },
    );
    final rawData = response.data as List;
    final propertiesList = rawData
        .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return {for (var property in propertiesList) property.id: property};
  }

  @override
  Future<Either<Failure, PropertyModel>> verifyProperty({
    required int propertyId,
    required double userLatitude,
    required double userLongitude,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.post(
        '/properties/$propertyId/verify',
        data: {
          'userLatitude': userLatitude,
          'userLongitude': userLongitude,
        },
      );
      return PropertyModel.fromJson(response.data);
    });
  }

  @override
  Future<Either<Failure, List<UserVerifiedPropertyModel>>>
      getUserVerifications() async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get('/users/verifications');

      final Map<String, dynamic> rawData = response.data;

      final List<dynamic> dataList = rawData['data'] as List<dynamic>;

      return dataList
          .map((json) =>
              UserVerifiedPropertyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<Either<Failure, PropertyModel>> getPropertyById(int id) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get('/properties/$id');
      return PropertyModel.fromJson(response.data);
    });
  }

  @override
  Future<Either<Failure, List<LightPropertyModel>>> getUserProperties(int userId) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get('/api/users/$userId/properties');
      
      final data = response.data as List;
      return data.map((json) => LightPropertyModel.fromJson(json)).toList();
    });
  }
}
