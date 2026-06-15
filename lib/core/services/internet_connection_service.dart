import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@singleton
class InternetConnectionService with WidgetsBindingObserver {
  final String healthCheckUrl = 'https://clients3.google.com/generate_204';
  final Duration debounceDuration = const Duration(seconds: 2);

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Stream<bool> get onStatusChange => _controller.stream;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _debounceTimer;
  bool? _lastStatus;
  bool _isInitialized = false;

  InternetConnectionService();

  /// Инициализация должна вызываться явно после создания синглтона
  @PostConstruct()
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    WidgetsBinding.instance.addObserver(this);

    // Проверка текущего состояния при старте
    await _checkAndUpdate();

    // Подписка на изменения типа сети
    _connectivitySub = Connectivity().onConnectivityChanged.listen(
          (results) {
        if (results.isNotEmpty &&
            !results.contains(ConnectivityResult.none)) {
          _scheduleCheck();
        } else {
          // Сразу обновляем статус при отсутствии подключения
          _updateStatus(false);
        }
      },
      onError: (error) {
        // Логирование ошибки или fallback
        _scheduleCheck();
      },
    );
  }

  void _scheduleCheck() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, _checkAndUpdate);
  }

  Future<void> _checkAndUpdate() async {
    final isOnline = await _hasInternetAccess();
    _updateStatus(isOnline);
  }

  void _updateStatus(bool isOnline) {
    if (_lastStatus != isOnline) {
      _lastStatus = isOnline;
      _controller.add(isOnline);
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

  /// Публичный метод для ручной проверки
  Future<void> checkConnectivity() async => _checkAndUpdate();

  /// Получить текущий статус без ожидания стрима
  bool? get currentStatus => _lastStatus;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleCheck();
    }
  }

  @disposeMethod
  void dispose() {
    _connectivitySub?.cancel();
    _debounceTimer?.cancel();
    _controller.close();
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
  }
}