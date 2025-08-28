part of 'create_community_form_cubit.dart';

@freezed
class CreateCommunityFormState with _$CreateCommunityFormState {
  const factory CreateCommunityFormState({
    String? name,
    String? nameError,
    String? code,
    String? codeError,
    @Default(false) bool isDeleting,
    @Default(false) bool isJoining,
    @Default(false) bool isCreating,
    String? error,
  }) = _CreateCommunityFormState;
}

