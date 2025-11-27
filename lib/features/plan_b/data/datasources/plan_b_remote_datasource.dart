import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/network/network_handler.dart';
import 'package:neighbours/features/plan_b/data/models/plan_b_category/plan_b_category_model.dart';
import 'package:neighbours/features/plan_b/data/models/plan_b_map/plan_b_map_model.dart';

abstract class PlanBRemoteDataSource {
  Future<Either<Failure, List<PlanBCategoryModel>>> getCategories();
  Future<Either<Failure, List<PlanBMapModel>>> getMapItems();
}

@Singleton(as: PlanBRemoteDataSource)
class PlanBRemoteDataSourceImpl implements PlanBRemoteDataSource {
  final Dio _dio;

  PlanBRemoteDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, List<PlanBCategoryModel>>> getCategories() async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get('/plan-b/categories');
      
      final data = response.data as List;
      return data
          .map((json) => PlanBCategoryModel.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<PlanBMapModel>>> getMapItems() async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get('/map/plan-b');
      
      final data = response.data as List;
      return data
          .map((json) => PlanBMapModel.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();
    });
  }
}

