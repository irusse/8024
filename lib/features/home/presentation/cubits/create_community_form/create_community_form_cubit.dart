import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/domain/entities/user/user_entity.dart';
import 'package:neighbours/features/community/domain/repositories/community_repository.dart';

part 'create_community_form_cubit.freezed.dart';

part 'create_community_form_state.dart';

@injectable
class CreateCommunityFormCubit extends Cubit<CreateCommunityFormState> {
  final CommunityRepository _repository;

  CreateCommunityFormCubit(this._repository)
      : super(const CreateCommunityFormState());
  int communityCodeLength = 6;

  void onNameChanged(String value) {
    final error = _validateName(value);
    emit(state.copyWith(
      name: value,
      nameError: error,
    ));
  }

  void onCommunityCodeChanged(String value) {
    final error = _validateCommunityCode(value);
    emit(state.copyWith(
      code: value,
      codeError: error,
    ));
  }

  bool isNameValid(String? name, String? nameError) {
    return name != null && nameError == null;
  }

  bool isCodeValid(String? code, String? codeError) {
    return code != null && codeError == null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validateCommunityCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите пригласительный код';
    }
    if (value.trim().length != communityCodeLength) {
      return 'Некорректный код';
    }
    return null;
  }

  bool isCreateEnabled() {
    final nameError = _validateName(state.name);

    return nameError == null;
  }

  bool isJoinEnabled() {
    final codeError = _validateCommunityCode(state.code);

    return codeError == null;
  }

  Future<UserEntity?> submit({
    required double userLatitude,
    required double userLongitude,
  }) async {
    if (state.name == null && state.code == null) {
      emit(state.copyWith(
        error: 'Одно из двух полей отсутствует',
      ));
      return null;
    }
    final isCreating = state.name != null;
    final isJoining = state.code != null;

    emit(state.copyWith(
      isCreating: isCreating,
      isJoining: isJoining,
      error: null,
    ));

    final result = isCreating
        ? await _repository.createCommunity(
            communityName: state.name!,
            userLatitude: userLatitude,
            userLongitude: userLongitude,
          )
        : await _repository.joinCommunity(
            communityCode: state.code!,
            userLatitude: userLatitude,
            userLongitude: userLongitude,
          );

    return result.fold(
      (failure) {
        emit(state.copyWith(
          isCreating: false,
          isJoining: false,
          error: failure.message,
        ));
        return null;
      },
      (user) {
        emit(state.copyWith(
          isCreating: false,
          isJoining: false,
          error: null,
        ));
        return user;
      },
    );
  }
}
