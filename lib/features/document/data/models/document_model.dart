import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/document_entity.dart';

part 'document_model.g.dart';

@JsonSerializable()
class DocumentModel {
  final String id;
  final String title;
  final String content;
  final String type;
  final DateTime updatedAt;

  DocumentModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentModelFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentModelToJson(this);

  /// Преобразование модели в Entity
  DocumentEntity toEntity() => DocumentEntity(
    id: id,
    title: title,
    content: content,
    type: type,
    updatedAt: updatedAt,
  );

  /// Создание модели из Entity
  factory DocumentModel.fromEntity(DocumentEntity entity) => DocumentModel(
    id: entity.id,
    title: entity.title,
    content: entity.content,
    type: entity.type,
    updatedAt: entity.updatedAt,
  );
}
