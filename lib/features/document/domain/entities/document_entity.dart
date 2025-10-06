import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_entity.freezed.dart';

@freezed
abstract class DocumentEntity with _$DocumentEntity {
  const factory DocumentEntity({
    required String id,
    required String title,
    required String content,
    required String type,
    required DateTime updatedAt,
  }) = _DocumentEntity;
}
