import 'package:flutter/material.dart';

class DeviceModel {
  final String id;
  final String name;
  final String type;
  final String connectionType;
  final int signalStrength;
  bool isConnected;

  DeviceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.connectionType,
    this.signalStrength = 0,
    this.isConnected = false,
  });

  IconData get icon {
    switch (type) {
      case 'laptop':
        return Icons.laptop_mac;
      case 'tablet':
        return Icons.tablet_mac;
      case 'desktop':
        return Icons.desktop_windows;
      default:
        return Icons.smartphone;
    }
  }
}
