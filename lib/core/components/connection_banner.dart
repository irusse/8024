import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'dart:async';

import 'package:neighbours/core/themes/theme.dart';

class ConnectionBanner extends StatefulWidget {
  final bool isConnected;

  const ConnectionBanner({
    super.key,
    required this.isConnected,
  });

  @override
  State<ConnectionBanner> createState() => _ConnectionBannerState();
}

class _ConnectionBannerState extends State<ConnectionBanner> {
  bool showBanner = false;
  bool wasConnected = true;
  String message = "";
  Color color = Colors.black;
  Timer? _timer;

  @override
  void didUpdateWidget(ConnectionBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isConnected) {
      _showBanner(
        "Интернет соединение прервано.\nВключен автономный режим",
        context.color.secondary,
      );
    } else {
      _showBanner(
        "Соединение восстановлено",
        CommonModeColors.green,
      );
    }
  }

  void _showBanner(String text, Color bgColor) {
    _timer?.cancel();
    setState(() {
      message = text;
      color = bgColor;
      showBanner = true;
    });

    // даже если persistent == true → запускаем таймер
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => showBanner = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top + 8;

    if (!showBanner) return const SizedBox.shrink();

    return Dismissible(
      key: const ValueKey("connection_banner"),
      direction: DismissDirection.up,
      onDismissed: (_) {
        setState(() => showBanner = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        height: paddingTop + 56,
        child: Material(
          elevation: 2,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: paddingTop,
              bottom: 8,
              left: 16,
              right: 16,
            ),
            color: color,
            child: Row(
              children: [
                Icon(
                  widget.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                  size: 20,
                ),
                const HorizontalGap(12),
                Expanded(
                  child: Text(
                    message,
                    style: context.text.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
