import 'package:dartz/dartz.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_category/plan_b_category_entity.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_map/plan_b_map_entity.dart';

abstract class PlanBRepository {
  Future<Either<Failure, List<PlanBCategoryEntity>>> getCategories();
  Future<Either<Failure, List<PlanBMapEntity>>> getMapItems();
}

