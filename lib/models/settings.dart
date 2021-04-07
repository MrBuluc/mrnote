import 'package:flutter/cupertino.dart';

class Settings {
  static Settings _settings;
  int lang;
  Color currentColor;
  bool adOpen = false;

  factory Settings() {
    if (_settings == null) {
      _settings = Settings.internal();
      return _settings;
    } else {
      return _settings;
    }
  }

  Settings.internal();
}
