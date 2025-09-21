part of 'community_access_cubit.dart';

@freezed
abstract class CommunityAccessState with _$CommunityAccessState {
  const factory CommunityAccessState({
    String? name,
    String? nameError,
    String? code,
    String? codeError,
  }) = _CommunityAccessState;
}
