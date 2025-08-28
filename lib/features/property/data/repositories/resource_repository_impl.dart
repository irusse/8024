import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import '../../domain/entities/resource/resource_entity.dart';
import '../../domain/repositories/resource_repository.dart';
import '../datasources/resource_remote_datasource.dart';

@Singleton(as: ResourceRepository)
class ResourceRepositoryImpl implements ResourceRepository {
  final ResourceRemoteDataSource remoteDataSource;

  ResourceRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ResourceEntity>> createResource({
    required String name,
    required String category,
    required int propertyId,
    XFile? photo,
  }) async {
    final result = await remoteDataSource.createResource(
      name: name,
      category: category,
      propertyId: propertyId,
      photo: photo,
    );
    return result.fold(
      (failure) => Left(failure),
      (model) => Right(model.toEntity()),
    );
  }

  @override
  Future<Either<Failure, void>> deleteResource(int id) async {
    return await remoteDataSource.deleteResource(id);
  }

  @override
  Future<Either<Failure, List<ResourceEntity>>> getResourcesByPropertyId(
      int propertyId) async {
    final result = await remoteDataSource.getResourcesByPropertyId(propertyId);
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.map((l) => l.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, ResourceEntity>> updateResource({
    required int id,
    required String name,
    required String category,
    XFile? photo,
  }) async {
    final result = await remoteDataSource.updateResource(
      id: id,
      name: name,
      category: category,
      photo: photo,
    );
    return result.fold(
      (failure) => Left(failure),
      (model) => Right(model.toEntity()),
    );
  }
}
