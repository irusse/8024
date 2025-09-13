import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/features/property/domain/entities/property/property_entity.dart';
import 'package:neighbours/features/property/domain/entities/user_verified_property/user_verified_property_entity.dart';

abstract class PropertyRepository {
  Future<Either<Failure, PropertyEntity>> add({
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    required double userLatitude,
    required double userLongitude,
    XFile? photo,
    bool isFirstProperty = false,
  });

  Future<Map<int, PropertyEntity>> fetchMyProperties();

  Future<Either<Failure, void>> deleteProperty(int propertyId);

  Future<PropertyEntity> updateProperty({
    required int id,
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    XFile? photo,
  });

  Future<Map<int, PropertyEntity>> fetchPropertiesByCommunityId(
      String communityId);

  Future<Map<int, PropertyEntity>> fetchUnverifiedOthersProperties({
    required double latitude,
    required double longitude,
    required double radius,
  });

  Future<Either<Failure, PropertyEntity>> verifyProperty({
    required int propertyId,
    required double userLatitude,
    required double userLongitude,
  });

  Future<Either<Failure, List<UserVerifiedPropertyEntity>>>
      getUserVerifications();

  Future<Either<Failure, PropertyEntity>> getPropertyById(int id);
}
