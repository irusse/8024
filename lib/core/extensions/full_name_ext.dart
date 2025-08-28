import '../mixins/has_name_mixin.dart';

extension FullNameExtension on HasName {
  String get fullName => (lastName != null && lastName!.isNotEmpty)
      ? '$firstName $lastName'
      : firstName;
}
