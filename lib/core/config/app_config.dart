import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AppConfig {
  static final String baseUrl = dotenv.env['HOST'] ??
      (throw Exception('HOST is not defined in .env file'));
  static final String mapBoxToken = dotenv.env['MAPBOX_TOKEN'] ??
      (throw Exception('MAPBOX_ACCESS_TOKEN is not defined in .env file'));
  static final String socketUrl = dotenv.env['SOCKET_URL'] ??
      (throw Exception('SOCKET_URL is not defined in .env file'));
  static final String shareLink = dotenv.env['SHARE_LINK'] ??
      (throw Exception('SHARE_LINK is not defined in .env file'));
}
