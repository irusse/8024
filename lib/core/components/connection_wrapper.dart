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

  @override
  void initState() {
    super.initState();
    _connectionService = getIt<InternetConnectionService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          StreamBuilder<bool?>(
            stream: _connectionService.onStatusChange,
            builder: (context, snapshot) {
              if (snapshot.data == null) return SizedBox.shrink();
              final isConnected = snapshot.data as bool;
              return Align(
                alignment: Alignment.topCenter,
                child: ConnectionBanner(isConnected: isConnected),
              );
            },
          ),
        ],
      ),
    );
  }
}
