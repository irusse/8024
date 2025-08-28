import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repository/document_repository.dart';
import '../datasources/document_data_source.dart';

@Singleton(as: DocumentRepository)
class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentDataSource _remoteDataSource;

  DocumentRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, DocumentEntity>> getDocumentByType(String type) async {
    final result = await _remoteDataSource.getDocumentByType(type);
    return result.fold(
      (failure) => Left(failure),
      (model) => Right(model.toEntity()),
    );
  }
}
