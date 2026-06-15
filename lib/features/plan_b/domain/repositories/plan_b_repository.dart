import 'package:dartz/dartz.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_category/plan_b_category_entity.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_details/plan_b_details_entity.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_map/plan_b_map_entity.dart';

abstract class PlanBRepository {
  Future<Either<Failure, List<PlanBCategoryEntity>>> getCategories();
  Future<Either<Failure, List<PlanBMapEntity>>> getMapItems();
  Future<Either<Failure, PlanBDetailsEntity>> getPlanBDetails(int id);
  Future<Either<Failure, (List<PlanBMapEntity>, int)>> getPlanBList({
    int take = 20,
    int skip = 0,
    int? categoryId,
    double? priceFrom,
    double? priceTo,
  });
}

