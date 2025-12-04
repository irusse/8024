import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/network/network_handler.dart';
import 'package:neighbours/features/plan_b/data/models/plan_b_category/plan_b_category_model.dart';
import 'package:neighbours/features/plan_b/data/models/plan_b_details/plan_b_details_model.dart';
import 'package:neighbours/features/plan_b/data/models/plan_b_map/plan_b_map_model.dart';
import 'package:neighbours/features/plan_b/data/models/plan_b_list_response/plan_b_list_response_model.dart';

abstract class PlanBRemoteDataSource {
  Future<Either<Failure, List<PlanBCategoryModel>>> getCategories();

  Future<Either<Failure, List<PlanBMapModel>>> getMapItems();

  Future<Either<Failure, PlanBDetailsModel>> getPlanBDetails(int id);

  Future<Either<Failure, PlanBListResponseModel>> getPlanBList({
    int take = 20,
    int skip = 0,
    int? categoryId,
    double? priceFrom,
    double? priceTo,
  });
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

  @override
  Future<Either<Failure, PlanBDetailsModel>> getPlanBDetails(int id) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get('/plan-b/$id');

      return PlanBDetailsModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  @override
  Future<Either<Failure, PlanBListResponseModel>> getPlanBList({
    int take = 20,
    int skip = 0,
    int? categoryId,
    double? priceFrom,
    double? priceTo,
  }) async {
    return NetworkHandler.handleRequest(() async {
      final queryParams = <String, dynamic>{
        'take': take,
        'skip': skip,
        'status': 'ACTIVE',
      };

      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }
      if (priceFrom != null) {
        queryParams['priceFrom'] = priceFrom;
      }
      if (priceTo != null) {
        queryParams['priceTo'] = priceTo;
      }

      final response = await _dio.get(
        '/api/plan-b',
        queryParameters: queryParams,
      );

      final responseData = response.data as Map<String, dynamic>;
      final items = (responseData['items'] as List)
          .map((json) => PlanBMapModel.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();

      return PlanBListResponseModel(
        items: items,
        total: responseData['total'] as int,
        skip: responseData['skip'] as int,
        take: responseData['take'] as int,
      );
    });
  }
}
