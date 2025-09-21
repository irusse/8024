import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbours/core/error/failures.dart';

abstract class HomeRepository {
  Future<Either<Failure, int>> getRegistrationStep();

  Future<Either<Failure, bool>> confirmAddress({
    required double latitude,
    required double longitude,
    required String address,
  });

  Future<Either<Failure, bool>> submitProperty({
    required String type,
    required double latitude,
    required double longitude,
    required String status,
    XFile? image,
  });
}
