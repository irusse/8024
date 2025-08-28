part of 'user_cubit.dart';

@freezed
class UserState with _$UserState {
  const factory UserState({
    required UserEntity user,
    @Default(ApiState<void>.initial()) ApiState<void> fetchState,
    @Default(ApiState<void>.initial()) ApiState<void> updateState,
    @Default(ApiState<SmsResponseEntity>.initial())
    ApiState<SmsResponseEntity> requestProfileDeletion,
    @Default(ApiState<ProfileDeletionEntity>.initial())
    ApiState<ProfileDeletionEntity> confirmProfileDeletion,
    @Default(ApiState<String>.initial()) ApiState<String> restoreProfile,
  }) = _UserState;

  factory UserState.initial() => const UserState(
        user: UserEntity(
          firstName: '',
          phone: '',
          communities: [],
          id: 0,
        ),
      );
}

extension UserStateX on UserState {
  /// Код из [SmsResponseEntity], если запрос на удаление профиля успешен
  String? get deletionRequestCode => requestProfileDeletion.maybeWhen(
        success: (data) => data.code,
        // предполагаем, что в SmsResponseEntity есть поле `code`
        orElse: () => null,
      );
}
