import 'package:flutter/material.dart';
import '../di/injection.dart';
import '../services/snackbar_service.dart';
import '../themes/theme.dart';

extension BuildContextExt on BuildContext {
  ThemeTextStyles get text => Theme.of(this).extension<ThemeTextStyles>()!;

  ThemeColors get color => Theme.of(this).extension<ThemeColors>()!;

  SnackbarService get snackbar => getIt<SnackbarService>();
}
