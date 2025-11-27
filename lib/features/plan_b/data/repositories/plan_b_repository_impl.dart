import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/features/plan_b/data/datasources/plan_b_remote_datasource.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_category/plan_b_category_entity.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_map/plan_b_map_entity.dart';
import 'package:neighbours/features/plan_b/domain/repositories/plan_b_repository.dart';

@Singleton(as: PlanBRepository)
class PlanBRepositoryImpl implements PlanBRepository {
  final PlanBRemoteDataSource _remoteDataSource;

  PlanBRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<PlanBCategoryEntity>>> getCategories() async {
    final result = await _remoteDataSource.getCategories();

    return result.fold(
      (failure) => Left(failure),
      (modelsList) => Right(
        modelsList.map((model) => model.toEntity()).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, List<PlanBMapEntity>>> getMapItems() async {
    final result = await _remoteDataSource.getMapItems();

    return result.fold(
      (failure) => Left(failure),
      (modelsList) => Right(
        modelsList.map((model) => model.toEntity()).toList(),
      ),
    );
  }
}

