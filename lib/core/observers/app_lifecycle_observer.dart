import 'package:flutter/widgets.dart';
import 'package:neighbours/core/di/injection.dart';
import 'package:neighbours/features/chat/data/socket/chat_socket.dart';

/// Интерфейс для кубитов, которые поддерживают autoRead функциональность
abstract class AutoReadSupport {
  int? get currentOpenChatId;
  void disableAutoRead(int chatId);
  void enableAutoRead(int chatId);
}

/// Единый observer для отслеживания lifecycle событий приложения
/// Управляет autoRead функциональностью для всех поддерживающих кубитов
class AppLifecycleObserver extends WidgetsBindingObserver {
  final List<AutoReadSupport> _cubits = [];

  /// Добавляет кубит для отслеживания
  void addCubit(AutoReadSupport cubit) {
    if (!_cubits.contains(cubit)) {
      _cubits.add(cubit);
    }
  }

  /// Удаляет кубит из отслеживания
  void removeCubit(AutoReadSupport cubit) {
    _cubits.remove(cubit);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Отключаем autoRead для всех активных чатов
        for (final cubit in _cubits) {
          if (cubit.currentOpenChatId != null) {
            cubit.disableAutoRead(cubit.currentOpenChatId!);
          }
        }
        break;
      case AppLifecycleState.resumed:
        // Проверяем и переподключаем сокеты при возврате в приложение
        _checkAndReconnectSockets();
        
        // Включаем autoRead для всех активных чатов
        for (final cubit in _cubits) {
          if (cubit.currentOpenChatId != null) {
            cubit.enableAutoRead(cubit.currentOpenChatId!);
          }
        }
        break;
      case AppLifecycleState.inactive:
        // Не обрабатываем состояние inactive
        break;
    }
  }

  /// Проверяет состояние сокетов и переподключает их при необходимости
  void _checkAndReconnectSockets() {
    try {
      final chatSocket = getIt<ChatSocket>();
      
      // Проверяем, действительно ли сокет подключен
      if (!chatSocket.isSocketReallyConnected) {
        // Принудительно переподключаем сокет
        chatSocket.forceReconnect();
      }
    } catch (e) {
      // Игнорируем ошибки, если сервис еще не инициализирован
    }
  }
}
