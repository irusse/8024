import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/network/network_handler.dart';
import '../models/resource/resource_model.dart';

abstract class ResourceRemoteDataSource {
  Future<Either<Failure, ResourceModel>> createResource({
    required String name,
    required String category,
    required int propertyId,
    XFile? photo,
  });

  Future<Either<Failure, void>> deleteResource(int id);

  Future<Either<Failure, List<ResourceModel>>> getResourcesByPropertyId(
      int propertyId);

  Future<Either<Failure, ResourceModel>> updateResource({
    required int id,
    required String name,
    required String category,
    XFile? photo,
  });
}

@Singleton(as: ResourceRemoteDataSource)
class ResourceRemoteDataSourceImpl implements ResourceRemoteDataSource {
  final Dio _dio;

  ResourceRemoteDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, ResourceModel>> createResource({
    required String name,
    required String category,
    required int propertyId,
    XFile? photo,
  }) async {
    return await NetworkHandler.handleRequest(() async {
      final formData = FormData.fromMap({
        'name': name.trim(),
        'category': category,
        'propertyId': propertyId,
        if (photo != null)
          'photo':
              await MultipartFile.fromFile(photo.path, filename: photo.name),
      });
      final response = await _dio.post(
        '/property-resources',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return ResourceModel.fromJson(response.data);
    });
  }

  @override
  Future<Either<Failure, void>> deleteResource(int id) async {
    return await NetworkHandler.handleRequest(() async {
      await _dio.delete('/property-resources/$id');
    });
  }

  @override
  Future<Either<Failure, List<ResourceModel>>> getResourcesByPropertyId(
      int propertyId) async {
    return await NetworkHandler.handleRequest(() async {
      final response =
          await _dio.get('/property-resources/property/$propertyId');

      final data = response.data as List;
      return data.map((json) => ResourceModel.fromJson(json)).toList();
    });
  }

  @override
  Future<Either<Failure, ResourceModel>> updateResource({
    required int id,
    required String name,
    required String category,
    XFile? photo,
  }) async {
    return await NetworkHandler.handleRequest(() async {
      final formData = FormData.fromMap({
        'name': name.trim(),
        'category': category,
        if (photo != null)
          'photo':
              await MultipartFile.fromFile(photo.path, filename: photo.name),
      });
      final response = await _dio.patch(
        '/property-resources/$id',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return ResourceModel.fromJson(response.data);
    });
  }
}
