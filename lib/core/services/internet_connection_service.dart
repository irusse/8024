import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@singleton
class InternetConnectionService with WidgetsBindingObserver {
  final String healthCheckUrl = 'https://clients3.google.com/generate_204';
  final int failureThreshold = 2;
  final Duration debounceDuration = const Duration(seconds: 2);

  final StreamController<bool?> _controller =
      StreamController<bool>.broadcast();

  Stream<bool?> get onStatusChange => _controller.stream;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  Timer? _debounceTimer;
  bool? _lastStatus;

  InternetConnectionService() {
    _init();
  }

  void _init() {
    WidgetsBinding.instance.addObserver(this);

    // 1️⃣ Проверка текущего состояния при старте
    Connectivity().checkConnectivity().then((_) => _checkAndUpdate());

    // 2️⃣ Подписка на изменения типа сети
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      _scheduleCheck();
    });
  }

  void _scheduleCheck() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () => _checkAndUpdate());
  }

  Future<void> _checkAndUpdate() async {
    final isOnline = await _hasInternetAccess();

    if (isOnline) {
      if (_lastStatus != true) {
        _lastStatus = true;
        _controller.add(true);
      }
    } else {
      if (_lastStatus != false) {
        _lastStatus = false;
        _controller.add(false);
      }
    }
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final response = await http
          .head(Uri.parse(healthCheckUrl))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  Future<void> checkConnectivity() async => _checkAndUpdate();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleCheck();
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _debounceTimer?.cancel();
    _controller.close();
    WidgetsBinding.instance.removeObserver(this);
  }
}
