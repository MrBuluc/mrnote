import 'package:flutter/cupertino.dart';

class Settings {
  static Settings _settings;
  int lang;
  Color currentColor;
  bool adOpen = true;
  static bool test = true;
  String gelistiriciSayfasiParola = "Hkcblc48";
  static final String appIDCanli = "ca-app-pub-2104543393026445~1095002395";
  static final String gecis1Canli = "ca-app-pub-2104543393026445/8249430070";
  static final String banner1Canli = "ca-app-pub-2104543393026445/3436743639";

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
