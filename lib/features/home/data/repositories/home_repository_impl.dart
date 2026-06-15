import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/features/home/data/datasources/home_remote_datasource.dart';
import '../../domain/repositories/home_repository.dart';

@Singleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, int>> getRegistrationStep() async {
    final result = await _remoteDataSource.getRegistrationStep();

    return result.fold(
      (failure) => Left(failure),
      (step) => Right(step),
    );
  }

  @override
  Future<Either<Failure, bool>> confirmAddress({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final result = await _remoteDataSource.confirmAddress(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );

    return result.fold(
      (failure) => Left(failure),
      (success) => Right(success),
    );
  }

  @override
  Future<Either<Failure, bool>> submitProperty({
    required String type,
    required double latitude,
    required double longitude,
    required String status,
    XFile? image,
  }) async {
    final result = await _remoteDataSource.submitProperty(
      type: type,
      latitude: latitude,
      longitude: longitude,
      status: status,
      image: image,
    );

    return result.fold(
      (failure) => Left(failure),
      (success) => Right(success),
    );
  }
}
