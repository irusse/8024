import 'package:dartz/dartz.dart';
import 'package:neighbours/core/error/failures.dart';
import '../entities/document_entity.dart';

abstract class DocumentRepository {
  Future<Either<Failure, DocumentEntity>> getDocumentByType(String type);
}
