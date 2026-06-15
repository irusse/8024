import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/state/api_state.dart';
import '../../../domain/entities/document_entity.dart';
import '../../../domain/repository/document_repository.dart';

part 'document_cubit.freezed.dart';

part 'document_state.dart';

@injectable
class DocumentCubit extends Cubit<DocumentState> {
  final DocumentRepository _documentRepository;

  DocumentCubit(this._documentRepository) : super(const DocumentState());

  Future<void> getDocumentByType(String type) async {
    _resetStates();
    emit(state.copyWith(fetchState: const ApiState.loading()));

    final result = await _documentRepository.getDocumentByType(type);

    result.fold(
      (failure) => emit(state.copyWith(
        fetchState: ApiState.failure(failure.message),
      )),
      (document) => emit(state.copyWith(
        document: document,
        fetchState: const ApiState.success(null),
      )),
    );
  }

  void _resetStates() {
    emit(state.copyWith(fetchState: const ApiState.initial()));
  }
}
