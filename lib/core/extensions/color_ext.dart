import 'package:flutter/material.dart';

extension ColorExtension on Color {
  String toHex() {
    return '#${toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  static Color byIndex(int id) {
    const colors = Colors.primaries;
    int hash = id ^ (id >> 16);
    return colors[hash.abs() % colors.length];
  }
}
