import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/features/property/domain/entities/user_verified_property/user_verified_property_entity.dart';
import 'package:neighbours/features/property/domain/repositories/property_repository.dart';
import 'package:neighbours/core/state/api_state.dart';

part 'user_verified_properties_cubit.freezed.dart';

part 'user_verified_properties_state.dart';

@Injectable()
class UserVerifiedPropertiesCubit extends Cubit<UserVerifiedPropertiesState> {
  final PropertyRepository _propertyRepository;

  UserVerifiedPropertiesCubit(this._propertyRepository)
      : super(const UserVerifiedPropertiesState());

  Future<void> fetchUserVerifications() async {
    emit(state.copyWith(fetchState: const ApiState.loading()));

    final result = await _propertyRepository.getUserVerifications();

    result.fold(
      (failure) {
        emit(state.copyWith(fetchState: ApiState.failure(failure.message)));
      },
      (verifications) {
        emit(state.copyWith(
          verifications: verifications,
          fetchState: const ApiState.success(null),
        ));
      },
    );
  }

  void clear() {
    emit(const UserVerifiedPropertiesState());
  }
}
