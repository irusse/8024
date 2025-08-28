import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/network/network_handler.dart';

import '../models/document_model.dart';

abstract class DocumentDataSource {
  Future<Either<Failure, DocumentModel>> getDocumentByType(String type);
}

@Singleton(as: DocumentDataSource)
class DocumentDataSourceImpl implements DocumentDataSource {
  final Dio _dio;

  DocumentDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, DocumentModel>> getDocumentByType(String type) async {
    return NetworkHandler.handleRequest(() async {
      final response = await _dio.get('/documents/$type');
      return DocumentModel.fromJson(response.data);
    });
  }
}
