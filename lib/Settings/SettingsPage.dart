import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mrnote/Settings/DeveloperPage.dart';
import 'package:mrnote/common_widget/platform_duyarli_alert_dialog.dart';
import 'package:mrnote/models/notes.dart';
import 'package:mrnote/utils/admob_helper.dart';
import 'package:mrnote/utils/database_helper.dart';

class SettingsPage extends StatefulWidget {
  int lang;
  Color color;
  bool adOpen;

  SettingsPage(this.lang, this.color, this.adOpen);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  InterstitialAd myInterstitialAd;

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
    "Container_Padding1": "Theme Color :",
    "AlertDialog": 'Select a color',
    "RaisedButtonText": "Select Color",
    "Container_Padding2": "Current Password:",
    "Container_Padding2_hintText": "Enter Password",
    "Container_Padding2_labelText": "Mr. Note Password",
    "Container_Padding3": "New Password:",
    "password_save_baslik": "Do you want to remove the password?",
    "password_save_icerik":
        "If you approve this process, password will be removed.",
    "password_save_anaButonYazisi": "Approve",
    "password_save_iptalButonYazisi": "Cancel",
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
    "Container_Padding1": "Tema Rengi :",
    "AlertDialog": 'Bir Renk Seçin',
    "RaisedButtonText": "Renk Seç",
    "Container_Padding2": "Mevcut Şifre:",
    "Container_Padding2_hintText": "Mr. Notun Parolasını Girin",
    "Container_Padding2_labelText": "Mr. Notun Parolası",
    "Container_Padding3": "Yeni Parola:",
    "password_save_baslik": "Parolayı Kaldırmak İstiyor Musunuz?",
    "password_save_icerik": "Bu işlemi onaylarsanız şifre kaldırılacaktır.",
    "password_save_anaButonYazisi": "Onayla",
    "password_save_iptalButonYazisi": "İptal",
  };

  Color currentColor;

  bool adOpen, show = false;

  double ekranYuksekligi, ekranGenisligi;

  static GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static GlobalKey<FormState> formKey1 = GlobalKey<FormState>();

  String gelistiriciSayfasiParola,
      password = "",
      newPassword,
      showPassword = "";

  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.adOpen) {
      adInitialize();
    }
    switch (widget.lang) {
      case 0:
        texts = english;
        break;
      case 1:
        texts = turkish;
        break;
    }
    currentColor = widget.color;
    readPassword();
  }

  @override
  void dispose() {
    if (widget.adOpen) {
      disposeAd();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ekranGenisligi = MediaQuery.of(context).size.width;
    ekranYuksekligi = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(texts["AppBar_title"]),
        backgroundColor: currentColor,
        actions: [
          FlatButton(
            color: Colors.red.shade600,
            textColor: Colors.black,
            child: Text(
              texts["AppBar_FlatButton"],
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              save(widget.lang, widget.color, widget.adOpen);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
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
                            widget.lang = selectedLang;
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      texts["Container_Padding1"],
                      style: TextStyle(fontSize: 20, color: Colors.blue),
                    ),
                  ),
                  RaisedButton(
                    elevation: 3.0,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(texts["AlertDialog"]),
                            content: SingleChildScrollView(
                              child: BlockPicker(
                                pickerColor: currentColor,
                                onColorChanged: (Color color) {
                                  Navigator.pop(context);
                                  changeColor(color);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(texts["RaisedButtonText"]),
                    color: currentColor,
                    textColor: const Color(0xffffffff),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                    child: Text(
                      texts["Container_Padding2"],
                      style: TextStyle(fontSize: 20, color: Colors.blue),
                    ),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                    child: Text(
                      show ? password : showPassword,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  password != "" || password != null
                      ? GestureDetector(
                    child: Icon(
                      show ? Icons.visibility_off : Icons.visibility,
                      size: 30,
                    ),
                    onTap: () {
                      setState(() {
                        show = !show;
                      });
                    },
                  )
                      : Container()
                ],
              ),
              Form(
                key: formKey1,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 15),
                      child: Text(
                        texts["Container_Padding3"],
                        style: TextStyle(fontSize: 20, color: Colors.blue),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: texts["Container_Padding2_hintText"],
                            labelText: texts["Container_Padding2_labelText"],
                            border: OutlineInputBorder(),
                          ),
                          onSaved: (text) {
                            newPassword = text;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                child: Container(
                  color: Colors.white,
                  child: SizedBox(
                    width: ekranGenisligi,
                    height: ekranYuksekligi - 332,
                  ),
                ),
                onLongPress: () async {
                  final sonuc = await _showMyDialog();
                  if (sonuc) {
                    gelistiriciSayfasiGiris();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void adInitialize() {
    AdmobHelper.admobInitialize();
    myInterstitialAd = AdmobHelper.buildInterstitialAd();
    myInterstitialAd
      ..load()
      ..show();
    AdmobHelper.myBannerAd = AdmobHelper.buildBannerAd();
    AdmobHelper.myBannerAd
      ..load()
      ..show(anchorOffset: 10);
  }

  void disposeAd() {
    myInterstitialAd.dispose();
    AdmobHelper.myBannerAd.dispose();
  }

  Future<void> readPassword() async {
    List<Note> noteList =
    await databaseHelper.getNoteTitleNotesList("Password");
    setState(() {
      password = noteList[0].noteContent;
    });
    if (password != "" || password != null) {
      prepareShowPassword();
    }
    debugPrint("password: " + password.toString());
  }

  void prepareShowPassword() {
    showPassword = "*" * (password.length);
  }

  List<DropdownMenuItem<int>> createLangItem() {
    List<String> langList = [texts["langList0"], texts["langList1"]];
    return langList
        .map((lang) =>
        DropdownMenuItem<int>(
          value: langList.indexOf(lang),
          child: Text(
            lang,
            style: TextStyle(fontSize: 20),
          ),
        ))
        .toList();
  }

  Future<void> save(int lang, Color color, bool adOpen) async {
    try {
      var suan = DateTime.now();
      databaseHelper.updateNote(
          Note.withID(2, 0, "Language", lang.toString(), suan.toString(), 2));

      databaseHelper.updateNote(Note.withID(
          3, 0, "Theme", color.value.toString(), suan.toString(), 2));

      formKey1.currentState.save();
      if (newPassword == "") {
        bool sonuc = await PlatformDuyarliAlertDialog(
          baslik: texts["password_save_baslik"],
          icerik: texts["password_save_icerik"],
          anaButonYazisi: texts["password_save_anaButonYazisi"],
          iptalButonYazisi: texts["password_save_iptalButonYazisi"],
        ).goster(context);
        if (sonuc) {
          databaseHelper.updateNote(
              Note.withID(1, 0, "Password", newPassword, suan.toString(), 2));
        }
      } else {
        var suan = DateTime.now();
        databaseHelper.updateNote(
            Note.withID(1, 0, "Password", newPassword, suan.toString(), 2));
      }
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
      String result1 = "${lang.toString()}/${color.value.toString()}/";
      if (widget.adOpen) {
        result1 += "1/";
      } else {
        result1 += "0/";
      }
      Navigator.pop(context, result1);
    }
  }

  void changeColor(Color color) {
    setState(() {
      currentColor = color;
      widget.color = color;
    });
  }

  Future<bool> _showMyDialog() async {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Geliştirici Sayfası Giriş"),
            content: Form(
              key: formKey,
              child: TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Parola",
                  prefixIcon: Icon(
                    Icons.lock,
                  ),
                ),
                onSaved: (String value) => gelistiriciSayfasiParola = value,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Iptal",
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text(
                  "Onayla",
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        });
  }

  Future<void> gelistiriciSayfasiGiris() async {
    formKey.currentState.save();
    if (gelistiriciSayfasiParola == "Hakkican99") {
      var result = await _goToPage(DeveloperPage(widget.adOpen));
      if (result != null) {
        if (result == "0") {
          setState(() {
            adOpen = false;
          });
        } else {
          adInitialize();
          setState(() {
            adOpen = true;
          });
        }
        setState(() {
          widget.adOpen = adOpen;
        });
      } else {
        setState(() {});
      }
    }
  }

  Future<String> _goToPage(Object page) async {
    final result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => page));
    return result;
  }
}
