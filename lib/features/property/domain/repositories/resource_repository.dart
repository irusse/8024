import 'package:dartz/dartz.dart';
import 'package:neighbours/core/error/failures.dart';

import '../../domain/entities/resource/resource_entity.dart';
import 'package:image_picker/image_picker.dart';

abstract class ResourceRepository {
  Future<Either<Failure, ResourceEntity>> createResource({
    required String name,
    required String category,
    required int propertyId,
    XFile? photo,
  });

  Future<Either<Failure, void>> deleteResource(int id);

  Future<Either<Failure,List<ResourceEntity>>> getResourcesByPropertyId(int propertyId);

  Future<Either<Failure, ResourceEntity>> updateResource({
    required int id,
    required String name,
    required String category,
    XFile? photo,
  });
}
