import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/extensions/placemark_ext.dart';

import '../../../../../core/services/map_service.dart';
import '../../../domain/repositories/home_repository.dart';

part 'auth_location_cubit.freezed.dart';

part 'auth_location_state.dart';

@injectable
class AuthLocationCubit extends Cubit<AuthLocationState> {
  final HomeRepository _homeRepository;

  AuthLocationCubit(this._homeRepository)
      : super(const AuthLocationState.initial());

  Future<void> submitAddress(
    LatLng coordinates,
    Placemark place,
  ) async {
    emit(const AuthLocationState.sending());

    try {
      final address = place.title;
      await _homeRepository.confirmAddress(
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
          address: address);

      emit(AuthLocationState.sendSuccess(coordinates, place));
    } catch (e) {
      emit(AuthLocationState.sendError('Ошибка при отправке: $e'));
    }
  }

}
