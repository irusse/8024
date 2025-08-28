import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/network/network_handler.dart';

import '../../../../core/data/models/user/user_model.dart';

abstract class HomeRemoteDataSource {
  Future<Either<Failure, int>> getRegistrationStep();

  Future<Either<Failure, bool>> confirmAddress({
    required double latitude,
    required double longitude,
    required String address,
  });

  Future<Either<Failure, UserModel>> submitProfile({
    required String name,
    required String surname,
    required String email,
    XFile? image,
  });

  Future<Either<Failure, bool>> submitProperty({
    required String type,
    required double latitude,
    required double longitude,
    required String status,
    XFile? image,
  });
}

@Singleton(as: HomeRemoteDataSource)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio _dio;

  HomeRemoteDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, int>> getRegistrationStep() async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/registration/step',
      );
      return response.data!['step'];
    });
  }

  @override
  Future<Either<Failure, bool>> confirmAddress({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.post(
        '/users/registration/step-one',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
        },
      );
      return response.statusCode == 201;
    });
  }

  @override
  Future<Either<Failure, UserModel>> submitProfile({
    required String name,
    required String surname,
    required String email,
    XFile? image,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final formData = FormData.fromMap({
        'firstName': name.trim(),
        if (surname.trim().isNotEmpty) 'lastName': surname.trim(),
        if (email.trim().isNotEmpty) 'email': email.trim(),
        if (image != null)
          'avatar':
              await MultipartFile.fromFile(image.path, filename: image.name),
      });

      final response = await _dio.post(
        '/users/registration/step-two',
        data: formData,
      );

      if (response.statusCode == 201) {
        final userResponse = await _dio.get('/users/me');
        return UserModel.fromJson(userResponse.data);
      } else {
        throw Exception('Ошибка при создании пользователя');
      }
    });
  }

  @override
  Future<Either<Failure, bool>> submitProperty({
    required String type,
    required double latitude,
    required double longitude,
    required String status,
    XFile? image,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final formData = FormData.fromMap({
        'type': type,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        if (image != null)
          'photo':
              await MultipartFile.fromFile(image.path, filename: image.name),
      });

      final response = await _dio.post(
        '/users/registration/step-three',
        data: formData,
      );
      return response.statusCode == 200;
    });
  }
}
