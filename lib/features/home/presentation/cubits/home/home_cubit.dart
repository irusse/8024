import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/constants/default_constants.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/services/map_service.dart';
import '../../../domain/repositories/home_repository.dart';

part 'home_state.dart';

@singleton
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  int step = DefaultConstants.addressNeedStep;

  HomeCubit(this._homeRepository) : super(const Loading());

  Future<void> start() async {
    emit(const Loading());

    final result = await _homeRepository.getRegistrationStep();

    result.fold(
      (failure) {
        if (failure is NetworkFailure) {
          emit(NetworkError(message: failure.message));
        } else {
          emit(GetStepError(message: failure.message));
        }
      },
      (result) {
        step = result;
        switch (step) {
          case DefaultConstants.addressNeedStep:
            emit(const ShowAddressStep());
            break;
          case DefaultConstants.userInfoNeedStep:
            emit(const ShowUserInfoStep());
            break;
          case DefaultConstants.propertyNeedStep:
            emit(const ShowAddPropertyStep());
            break;
          case DefaultConstants.communityNeedStep:
            emit(const ShowNoActiveCommunities());
            break;
          default:
            emit(const Idle());
        }
      },
    );
  }

  bool isFirstProperty() => step <= DefaultConstants.propertyNeedStep;

  void goToUserInfoStep() {
    emit(const ShowUserInfoStep());
  }

  void showNoActiveCommunities() {
    emit(const Idle());
    emit(const ShowNoActiveCommunities());
  }

  void incrementStep() => step++;

  void goToAddPropertyStep() {
    setIdle();
    emit(const ShowAddPropertyStep());
  }

  void setIdle() {
    emit(const Idle());
  }

  void showSetCoordinates() {
    emit(const ShowSetCoordinates());
  }

  bool canOpenProfile() {
    return step > DefaultConstants.userInfoNeedStep;
  }

  bool isMarkerVisible() {
    return state is ShowSetCoordinates;
  }

  void showAddEvent() {
    emit(const Idle());
    emit(const ShowAddEvent());
  }

  void handleEventStepNavigation() {
    if (step > DefaultConstants.communityNeedStep) {
      showAddEvent();
    } else {
      if (step > DefaultConstants.propertyNeedStep) {
        showNoActiveCommunities();
      } else {
        goToAddPropertyStep();
      }
    }
  }
}
