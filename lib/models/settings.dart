import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static Settings _settings;
  int lang;
  Color currentColor;
  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool adOpen;
  static bool test = false;
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

  Future<void> getAdOpen() async {
    final SharedPreferences prefs = await _prefs;
    try {
      adOpen = prefs.getBool("adOpen");
      if (adOpen == null) {
        throw Exception();
      }
    } catch (e) {
      prefs.setBool("adOpen", true);
      adOpen = true;
    }
  }

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
