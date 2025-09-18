import 'package:flutter/material.dart';
import 'package:neighbours/core/components/connection_banner.dart';
import 'package:neighbours/core/services/internet_connection_service.dart';
import 'package:neighbours/core/di/injection.dart';

class ConnectionWrapper extends StatefulWidget {
  final Widget child;

  const ConnectionWrapper({
    super.key,
    required this.child,
  });

  @override
  State<ConnectionWrapper> createState() => _ConnectionWrapperState();
}

class _ConnectionWrapperState extends State<ConnectionWrapper> {
  late final InternetConnectionService _connectionService;
  late final ValueNotifier<bool> _internetState;

  @override
  void initState() {
    super.initState();
    _connectionService = getIt<InternetConnectionService>();
    _internetState = _connectionService.internetState;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _internetState,
            builder: (context, isConnected, _) {
              return ConnectionBanner(
                isConnected: isConnected,
              );
            },
          ),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
