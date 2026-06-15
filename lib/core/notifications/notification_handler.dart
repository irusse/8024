abstract class NotificationHandler {
  String get type;

  void handle(Map<String, dynamic> payload);
}
