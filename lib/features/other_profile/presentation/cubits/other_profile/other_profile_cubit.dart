import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/other_profile/domain/entities/other_user/other_user_entity.dart';
import 'package:neighbours/features/other_profile/domain/repositories/other_profile_repository.dart';

part 'other_profile_state.dart';

part 'other_profile_cubit.freezed.dart';

@Injectable()
class OtherProfileCubit extends Cubit<OtherProfileState> {
  final OtherProfileRepository _repository;

  OtherProfileCubit(this._repository) : super(const OtherProfileState());

  /// Получить информацию о пользователе по ID
  Future<void> fetchUser(int userId) async {
    emit(state.copyWith(fetchUserState: const ApiState.loading()));

    final result = await _repository.getUserById(userId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          fetchUserState: ApiState.failure(failure.message),
        ));
      },
      (user) {
        emit(state.copyWith(
          user: user,
          fetchUserState: const ApiState.success(null),
        ));
      },
    );
  }
}
