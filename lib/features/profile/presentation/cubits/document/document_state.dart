part of 'document_cubit.dart';

@freezed
abstract class DocumentState with _$DocumentState {
  const factory DocumentState({
    DocumentEntity? document,
    @Default(ApiState<void>.initial()) ApiState<void> fetchState,
  }) = _DocumentState;
}
