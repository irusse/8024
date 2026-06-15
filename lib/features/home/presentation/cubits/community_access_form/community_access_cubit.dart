import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'community_access_state.dart';

part 'community_access_cubit.freezed.dart';

@injectable
class CommunityAccessCubit extends Cubit<CommunityAccessState> {
  CommunityAccessCubit() : super(const CommunityAccessState());

  final int _communityCodeLength = 6;

  int get communityCodeLength => _communityCodeLength;

  void onNameChanged(String value) {
    emit(state.copyWith(
      name: value,
      nameError: _validateName(value),
    ));
  }

  void onCodeChanged(String value) {
    emit(state.copyWith(
      code: value,
      codeError: _validateCommunityCode(value),
    ));
  }

  bool isCreateEnabled() {
    return _validateName(state.name) == null;
  }

  bool isJoinEnabled() {
    return _validateCommunityCode(state.code) == null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Название обязательно';
    }
    if (value.trim().length < 3) {
      return 'Минимум 3 символа';
    }
    return null;
  }

  String? _validateCommunityCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите пригласительный код';
    }
    if (value.trim().length != _communityCodeLength) {
      return 'Некорректный код';
    }
    return null;
  }
}
