import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:neighbours/core/data/models/profile_deletetion/profile_deletion_model.dart';
import 'package:neighbours/core/exceptions/exceptions.dart';
import 'package:neighbours/core/network/network_handler.dart';

import '../../error/failures.dart';
import '../models/user/user_model.dart';
import '../models/sms_response/sms_response_model.dart';

abstract class UserRemoteDataSource {
  Future<Either<Failure, UserModel>> fetchUser();

  Future<Either<Failure, UserModel>> updateUser(UserModel user,
      {XFile? avatarFile});

  Future<Either<Failure, SmsResponseModel>> requestProfileDeletion();

  Future<Either<Failure, ProfileDeletionModel>> confirmProfileDeletion(
      String code);

  Future<Either<Failure, String>> restoreProfile();

  Future<Either<Failure, UserModel>> submitProfile({
    required String name,
    required String surname,
    required String email,
    XFile? image,
  });
}

@Singleton(as: UserRemoteDataSource)
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio _dio;

  UserRemoteDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, UserModel>> fetchUser() async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get('/users/me');
      return UserModel.fromJson(response.data);
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
        throw BadRequestException("Ошибка при создании пользователя");
      }
    });
  }

  @override
  Future<Either<Failure, UserModel>> updateUser(UserModel user,
      {XFile? avatarFile}) async {
    final data = <String, dynamic>{};
    user.toJson().forEach((key, value) {
      if (value != null && (value is String && value.trim().isNotEmpty)) {
        data[key] = value;
      }
    });
    if (avatarFile != null) {
      data['avatar'] = await MultipartFile.fromFile(
        avatarFile.path,
        filename: avatarFile.name,
      );
    }
    final formData = FormData.fromMap(data);
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.patch('/users/me', data: formData);
      return UserModel.fromJson(response.data);
    });
  }

  @override
  Future<Either<Failure, SmsResponseModel>> requestProfileDeletion() async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.post('/profile/delete-request');
      return SmsResponseModel.fromJson(response.data);
    });
  }

  @override
  Future<Either<Failure, ProfileDeletionModel>> confirmProfileDeletion(
      String code) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.post(
        '/profile/confirm-delete',
        data: {'code': code},
      );
      return ProfileDeletionModel.fromJson(response.data);
    });
  }

  @override
  Future<Either<Failure, String>> restoreProfile() async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.post('/profile/restore');
      return response.data['message'];
    });
  }
}
