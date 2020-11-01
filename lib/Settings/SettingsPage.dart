import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:mrnote/common_widget/platform_duyarli_alert_dialog.dart';
import 'package:mrnote/utils/admob_helper.dart';
import 'package:path_provider/path_provider.dart';

class SettingsPage extends StatefulWidget {
  int lang;

  SettingsPage({this.lang});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  InterstitialAd myInterstitialAd;

  int lang = 0;

  Map<String, String> texts;

  Map<String, String> english = {
    "AppBar_title": "Settings",
    "AppBar_FlatButton": "Save",
    "Container_Padding": "Languages :",
    "langList0": "English",
    "langList1": "Turkish",
    "save_catch_baslik": "Save Failed ❌",
    "save_catch_icerik": "Error: ",
    "save_catch_anaButonYazisi": "Ok",
    "save_baslik": "Saved Successfully ✔",
    "save_icerik": "✔✔✔✔✔✔✔✔✔✔✔✔✔✔✔",
    "save_anaButonYazisi": "Ok",
  };

  Map<String, String> turkish = {
    "AppBar_title": "Ayarlar",
    "AppBar_FlatButton": "Kaydet",
    "Container_Padding": "Diller :",
    "langList0": "İngilizce",
    "langList1": "Türkçe",
    "save_catch_baslik": "Kaydetme Başarısız Oldu ❌",
    "save_catch_icerik": "Hata: ",
    "save_catch_anaButonYazisi": "Tamam",
    "save_baslik": "Başarılı Bir Şekilde Kaydedildi ✔",
    "save_icerik": "✔✔✔✔✔✔✔✔✔✔✔✔✔✔✔",
    "save_anaButonYazisi": "Tamam",
  };

  @override
  void initState() {
    super.initState();
    // AdmobHelper.admobInitialize();
    // myInterstitialAd = AdmobHelper.buildInterstitialAd();
    // myInterstitialAd
    //   ..load()
    //   ..show();
    // AdmobHelper.myBannerAd = AdmobHelper.buildBannerAd();
    // AdmobHelper.myBannerAd
    //   ..load()
    //   ..show(anchorOffset: 10);
    switch (widget.lang) {
      case 0:
        texts = english;
        break;
      case 1:
        texts = turkish;
        break;
    }
  }

  @override
  void dispose() {
    myInterstitialAd.dispose();
    AdmobHelper.myBannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(texts["AppBar_title"]),
        actions: [
          FlatButton(
            color: Colors.red.shade600,
            textColor: Colors.black,
            child: Text(
              texts["AppBar_FlatButton"],
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              save(lang);
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    texts["Container_Padding"],
                    style: TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      items: createLangItem(),
                      value: widget.lang,
                      onChanged: (selectedLang) {
                        setState(() {
                          lang = selectedLang;
                          widget.lang = selectedLang;
                        });
                      },
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<int>> createLangItem() {
    List<String> langList = [texts["langList0"], texts["langList1"]];
    return langList
        .map((lang) => DropdownMenuItem<int>(
              value: langList.indexOf(lang),
              child: Text(
                lang,
                style: TextStyle(fontSize: 20),
              ),
            ))
        .toList();
  }

  Future<void> save(int lang) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File("$path/settings.txt");
      file.writeAsString("language: $lang");
    } catch (e) {
      PlatformDuyarliAlertDialog(
        baslik: texts["save_catch_baslik"],
        icerik: texts["save_catch_icerik"] + e.toString(),
        anaButonYazisi: texts["save_catch_anaButonYazisi"],
      ).goster(context);
    }
    final result = await PlatformDuyarliAlertDialog(
      baslik: texts["save_baslik"],
      icerik: texts["save_icerik"],
      anaButonYazisi: texts["save_anaButonYazisi"],
    ).goster(context);
    if (result) {
      Navigator.pop(context, lang.toString());
    }
  }
}
