import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

extension RouterExtensions on GoRouter {
  void navigateUnique(String location) {
    if (state.matchedLocation == location) {
      replace(location, extra: UniqueKey());
    } else {
      push(location);
    }
  }
}
