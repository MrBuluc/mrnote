import 'package:flutter/material.dart';

class Settings {
  static Settings? _settings;
  int? lang;
  Color? currentColor;

  factory Settings() {
    if (_settings == null) {
      _settings = Settings.internal();
      return _settings!;
    } else {
      return _settings!;
    }
  }

  Settings.internal();

  Color switchBackgroundColor() {
    switch (currentColor.hashCode) {
      //black color
      case 4278190080:
        return Colors.grey.shade600;
      default:
        return Colors.white;
    }
  }
}
