import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_details/plan_b_details_entity.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_map/plan_b_map_entity.dart';
import 'package:neighbours/features/plan_b/domain/repositories/plan_b_repository.dart';

part 'plan_b_cubit.freezed.dart';

part 'plan_b_state.dart';

@singleton
class PlanBCubit extends Cubit<PlanBState> {
  final PlanBRepository _planBRepository;

  PlanBCubit(this._planBRepository) : super(const PlanBState());

  Future<void> getMapItems() async {
    _resetStates();
    emit(state.copyWith(fetchState: const ApiState.loading()));

    final result = await _planBRepository.getMapItems();

    result.fold(
      (failure) => emit(state.copyWith(
        fetchState: ApiState.failure(failure.message),
      )),
      (items) => emit(state.copyWith(
        items: items,
        fetchState: const ApiState.success(null),
      )),
    );
  }

  Future<void> getPlanBDetails(int id) async {
    emit(state.copyWith(detailsState: const ApiState.loading()));

    final result = await _planBRepository.getPlanBDetails(id);

    result.fold(
      (failure) => emit(state.copyWith(
        detailsState: ApiState.failure(failure.message),
      )),
      (details) => emit(state.copyWith(
        detailsState: ApiState.success(details),
      )),
    );
  }

  Future<void> getPlanBList({
    bool loadMore = false,
    int? categoryId,
    double? priceFrom,
    double? priceTo,
  }) async {
    if (!loadMore) {
      emit(state.copyWith(
        listState: const ApiState.loading(),
        items: [],
        skip: 0,
        total: 0,
        hasMore: false,
      ));
    }

    final skip = loadMore ? state.skip : 0;

    final result = await _planBRepository.getPlanBList(
      take: 20,
      skip: skip,
      categoryId: categoryId,
      priceFrom: priceFrom,
      priceTo: priceTo,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        listState: ApiState.failure(failure.message),
      )),
      (data) {
        final (items, total) = data;
        final allItems = loadMore ? [...state.items, ...items] : items;
        final newSkip = skip + items.length;
        final hasMore = newSkip < total;

        emit(state.copyWith(
          items: allItems,
          total: total,
          skip: newSkip,
          hasMore: hasMore,
          listState: const ApiState.success(null),
        ));
      },
    );
  }

  void _resetStates() {
    emit(state.copyWith(fetchState: const ApiState.initial()));
  }
}

