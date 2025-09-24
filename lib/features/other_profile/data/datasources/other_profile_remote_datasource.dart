import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/network/network_handler.dart';
import 'package:neighbours/features/other_profile/data/models/other_user/other_user_model.dart';

abstract class OtherProfileRemoteDataSource {
  /// Получить информацию о пользователе по ID
  Future<Either<Failure, OtherUserModel>> getUserById(int userId);
}

@Singleton(as: OtherProfileRemoteDataSource)
class OtherProfileRemoteDataSourceImpl implements OtherProfileRemoteDataSource {
  final Dio _dio;

  OtherProfileRemoteDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, OtherUserModel>> getUserById(int userId) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get('/users/$userId');
      return OtherUserModel.fromJson(response.data);
    });
  }
}
