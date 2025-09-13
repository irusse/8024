import 'package:freezed_annotation/freezed_annotation.dart';

part 'resource_entity.freezed.dart';

@freezed
abstract class ResourceEntity with _$ResourceEntity {
  const factory ResourceEntity({
    required int id,
    required String name,
    required String category,
    required int propertyId,
    String? photo,
  }) = _ResourceEntity;
}
