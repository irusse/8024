import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';


@singleton
class InternetConnectionService {
  final ValueNotifier<bool> internetState = ValueNotifier(true);

  Timer? _debounceTimer;

  InternetConnectionService() {
    _init();
  }

  void _init() {
    // первая проверка — сразу
    _checkAndUpdate();

    // все следующие — только с задержкой
    Connectivity().onConnectivityChanged.listen((_) => _scheduleCheck());
  }

  void _scheduleCheck() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _checkAndUpdate();
    });
  }

  Future<void> _checkAndUpdate() async {
    final isOnline = await _hasInternetAccess();
    internetState.value = isOnline;
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final response = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  Future<void> checkConnectivity() async {
    await _checkAndUpdate();
  }

  void dispose() {
    _debounceTimer?.cancel();
    internetState.dispose();
  }
}
