part of 'document_cubit.dart';

@freezed
class DocumentState with _$DocumentState {
  const factory DocumentState({
    DocumentEntity? document,
    @Default(ApiState<void>.initial()) ApiState<void> fetchState,
  }) = _DocumentState;
}
