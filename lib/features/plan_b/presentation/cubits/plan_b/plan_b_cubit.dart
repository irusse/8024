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

  void _resetStates() {
    emit(state.copyWith(fetchState: const ApiState.initial()));
  }
}

