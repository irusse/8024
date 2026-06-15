import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

class AppLogger {
  AppLogger._();

  static final Talker _talker = Talker(
    settings: TalkerSettings(
      colors: {
        TalkerKey.debug: AnsiPen()..cyan(),
        TalkerKey.info: AnsiPen()..magenta(),
        TalkerKey.warning: AnsiPen()..yellow(),
        TalkerKey.error: AnsiPen()..red(),
      },
      titles: {
        TalkerKey.debug: 'D',
        TalkerKey.info: 'i',
        TalkerKey.warning: 'W',
        TalkerKey.error: 'E',
        TalkerKey.exception: 'Exception',
      },
    ),
  );

  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final logMessage = tag != null ? "[$tag] $message" : message;
      _talker.debug(logMessage);
    }
  }

  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final logMessage = tag != null ? "[$tag] $message" : message;
      _talker.info(logMessage);
    }
  }

  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final logMessage = tag != null ? "[$tag] $message" : message;
      _talker.warning(logMessage);
    }
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final logMessage = tag != null ? "[$tag] $message" : message;
      _talker.error(logMessage, error, stackTrace);
    }
  }

  /// доступ к оригинальному Talker (например для TalkerScreen)
  static Talker get instance => _talker;
}
