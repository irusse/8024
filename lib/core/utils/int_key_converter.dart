import 'package:freezed_annotation/freezed_annotation.dart';

class IntKeyMapConverter
    implements JsonConverter<Map<int, int>, Map<String, dynamic>> {
  const IntKeyMapConverter();

  @override
  Map<int, int> fromJson(Map<String, dynamic> json) {
    return json.map(
      (key, value) => MapEntry(int.parse(key), value as int),
    );
  }

  @override
  Map<String, dynamic> toJson(Map<int, int> object) {
    return object.map(
      (key, value) => MapEntry(key.toString(), value),
    );
  }
}
