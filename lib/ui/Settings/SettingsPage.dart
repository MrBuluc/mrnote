import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mrnote/common_widget/Platform_Duyarli_Alert_Dialog/platform_duyarli_alert_dialog.dart';
import 'package:mrnote/models/note.dart';
import 'package:mrnote/models/settings.dart';

import '../../const.dart';
import '../../services/admob_helper.dart';
import '../../services/database_helper.dart';
import 'DeveloperPage.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  InterstitialAd myInterstitialAd;

  Map<String, String> texts;

  Map<String, String> english = {
    "AppBar_title": "Settings",
    "AppBar_FlatButton": "Save",
    "langList0": "English",
    "langList1": "Turkish",
    "Change Your Password": "Change Your Password",
    "Change Password": "Change Password",
    "Password": "Password",
    "save_catch_baslik": "Save Failed ❌",
    "save_catch_icerik": "Error: ",
    "save_catch_anaButonYazisi": "Ok",
    "save_baslik": "Saved Successfully ✔",
    "save_icerik": "✔✔✔✔✔✔✔✔✔✔✔✔✔✔✔",
    "save_anaButonYazisi": "Ok",
    "refresh_catch_baslik": "Refresh Failed ❌",
    "refresh_baslik": "Refresh Successfully ✔",
    "Theme_Color": "Theme Color:",
    "Currently_Password": "Currently Password:",
    "AlertDialog": 'Select a color',
    "RaisedButtonText": "Select Color",
    "password_save_baslik": "Do you want to remove the password?",
    "password_save_icerik":
        "If you approve this process, password will be removed.",
    "password_save_anaButonYazisi": "Approve",
    "password_save_iptalButonYazisi": "Cancel",
  };

  Map<String, String> turkish = {
    "AppBar_title": "Ayarlar",
    "AppBar_FlatButton": "Kaydet",
    "langList0": "İngilizce",
    "langList1": "Türkçe",
    "Change Your Password": "Parolanı Değiştir",
    "Change Password": "Parola Değiştir",
    "Password": "Parola",
    "save_catch_baslik": "Kaydetme Başarısız Oldu ❌",
    "save_catch_icerik": "Hata: ",
    "save_catch_anaButonYazisi": "Tamam",
    "save_baslik": "Başarılı Bir Şekilde Kaydedildi ✔",
    "save_icerik": "✔✔✔✔✔✔✔✔✔✔✔✔✔✔✔",
    "save_anaButonYazisi": "Tamam",
    "refresh_catch_baslik": "Varsayılana Dönmek Başarısız Oldu ❌",
    "refresh_baslik": "Başarılı Bir Şekilde Varsayılana Dönüldü ✔",
    "Theme_Color": "Tema Rengi:",
    "Currently_Password": "Şuanki Parola:",
    "AlertDialog": 'Bir Renk Seçin',
    "RaisedButtonText": "Renk Seç",
    "Container_Padding2": "Mevcut Şifre:",
    "password_save_baslik": "Parolayı Kaldırmak İstiyor Musunuz?",
    "password_save_icerik": "Bu işlemi onaylarsanız şifre kaldırılacaktır.",
    "password_save_anaButonYazisi": "Onayla",
    "password_save_iptalButonYazisi": "İptal",
  };

  bool show = false;

  double ekranYuksekligi, ekranGenisligi;

  String gelistiriciSayfasiParola,
      passwordStr = "",
      newPassword,
      showPassword = "";

  DatabaseHelper databaseHelper = DatabaseHelper();

  List<String> bos = [""];

  final myController = TextEditingController();

  static GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Settings settings = Settings();

  int lang;

  Color currentColor;

  @override
  void initState() {
    super.initState();
    if (settings.adOpen) {
      adInitialize();
    }
    readPassword();
    lang = settings.lang;
    currentColor = settings.currentColor;
  }

  @override
  void dispose() {
    if (settings.adOpen) {
      disposeAd();
    }
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (lang) {
      case 0:
        texts = english;
        break;
      case 1:
        texts = turkish;
        break;
    }
    Size size = MediaQuery.of(context).size;
    ekranGenisligi = size.width;
    ekranYuksekligi = size.height;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: currentColor,
        body: Column(
          children: [
            buildHeader(size),
            SizedBox(
              height: 10,
            ),
            dropDownButtonsColumn(),
            changeColorWidget(),
            SizedBox(
              height: 10,
            ),
            currentPassword(),
            SizedBox(
              height: 10,
            ),
            changePassword(bos, texts["Change Your Password"], size),
            saveButton(),
          ],
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
    try {
      Note password = await databaseHelper.getNoteIDNote(1);
      if (password != null) {
        setState(() {
          passwordStr = password.noteContent;
        });
        if (passwordStr != null) {
          prepareShowPassword();
        }
      }
    } catch (e) {
      setState(() {
        passwordStr = null;
      });
    }
  }

  void prepareShowPassword() {
    setState(() {
      showPassword = "*" * (passwordStr.length);
    });
  }

  Widget buildHeader(Size size) {
    return GestureDetector(
      child: Container(
        height: 200,
        width: ekranGenisligi,
        color: Colors.grey.shade900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                texts["AppBar_title"],
                style: headerStyle6,
              ),
            ),
          ],
        ),
      ),
      onLongPress: () async {
        final sonuc = await _showMyDialog();
        if (sonuc) {
          gelistiriciSayfasiGiris();
        }
      },
    );
  }

  Future<void> gelistiriciSayfasiGiris() async {
    formKey.currentState.save();
    if (gelistiriciSayfasiParola == "*****") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => DeveloperPage()));
    }
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

  Widget dropDownButtonsColumn() {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, bottom: 10, top: 12),
      child: Container(
        height: 55,
        width: ekranGenisligi - 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            color: Colors.grey),
        child: Theme(
            data: Theme.of(context).copyWith(
                canvasColor: Colors.grey.shade400,
                buttonTheme: ButtonTheme.of(context).copyWith(
                  alignedDropdown: true,
                )),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                iconEnabledColor: Colors.grey.shade400,
                items: createLangItem(),
                value: lang,
                onChanged: (selectedLang) {
                  setState(() {
                    lang = selectedLang;
                  });
                },
              ),
            )),
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
                style: headerStyle7,
              ),
            ))
        .toList();
  }

  Widget changeColorWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            texts["Theme_Color"],
            style: headerStyle7.copyWith(color: Colors.grey.shade900),
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
                      pickerColor: settings.currentColor,
                      onColorChanged: (Color color) {
                        setState(() {
                          currentColor = color;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            );
          },
          child: Text(
            texts["RaisedButtonText"],
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget currentPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 35),
          child: Text(
            texts["Currently_Password"],
            style: headerStyle7.copyWith(color: Colors.grey.shade900),
          ),
        ),
        Text(
          show ? passwordStr : showPassword,
          style: TextStyle(fontSize: 20),
        ),
        passwordStr != null
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
            : Container(
                width: 30,
              )
      ],
    );
  }

  Widget changePassword(List<String> list, String hint, Size size) {
    var bankSelected;
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, bottom: 24, top: 12),
      child: Container(
        height: 55,
        width: ekranGenisligi,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            color: Colors.grey.shade400),
        child: Theme(
            data: Theme.of(context).copyWith(
                canvasColor: Colors.grey.shade400,
                buttonTheme: ButtonTheme.of(context).copyWith(
                  alignedDropdown: true,
                )),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                iconEnabledColor: Colors.grey.shade400,
                items: list.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Container(
                      height: 200,
                      width: ekranGenisligi - 125,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            texts["Change Password"],
                            style: headerStyle3,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Form(child: buildForm())
                        ],
                      ),
                    ),
                  );
                }).toList(),
                hint: Text(
                  hint,
                  style: headerStyle7,
                ),
                onChanged: (String value) {
                  setState(() {
                    bankSelected = value;
                  });
                },
                value: bankSelected,
              ),
            )),
      ),
    );
  }

  Widget buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: myController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.black,
                ),
                hintText: texts["Password"],
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            RaisedButton(
              color: Colors.grey.shade800,
              onPressed: () {
                savePassword();
              },
              child: Text(
                texts["AppBar_FlatButton"],
                style: headerStyle7,
              ),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                texts["password_save_iptalButonYazisi"],
                style: headerStyle4,
              ),
            )
          ],
        )
      ],
    );
  }

  Widget saveButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 60.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3), color: Colors.black),
              height: 50,
              width: 50,
              child: Icon(
                Icons.refresh,
                color: Colors.white,
                size: 30,
              ),
            ),
            onTap: () {
              refreshLangTheme();
            },
          ),
          SizedBox(
            width: 150,
          ),
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3), color: Colors.black),
              height: 50,
              width: 50,
              child: Icon(
                Icons.save,
                color: Colors.white,
                size: 30,
              ),
            ),
            onTap: () {
              save();
            },
          ),
        ],
      ),
    );
  }

  Future<void> savePassword() async {
    try {
      var suan = DateTime.now();
      newPassword = myController.text;
      if (newPassword == "") {
        bool sonuc = await PlatformDuyarliAlertDialog(
          baslik: texts["password_save_baslik"],
          icerik: texts["password_save_icerik"],
          anaButonYazisi: texts["password_save_anaButonYazisi"],
          iptalButonYazisi: texts["password_save_iptalButonYazisi"],
        ).goster(context);
        if (sonuc) {
          databaseHelper.updateSettingsNote(
              Note.withID(1, 0, "Password", null, suan.toString(), 2));
        }
      } else {
        databaseHelper.updateSettingsNote(
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
      Navigator.pop(context);
      setState(() {});
    }
  }

  Future<void> save() async {
    try {
      settings.lang = lang;
      var suan = DateTime.now();
      databaseHelper.updateSettingsNote(
          Note(0, "Language", lang.toString(), suan.toString(), 2));

      settings.currentColor = currentColor;
      databaseHelper.updateSettingsNote(
          Note(0, "Theme", currentColor.value.toString(), suan.toString(), 2));
    } catch (e) {
      PlatformDuyarliAlertDialog(
        baslik: texts["save_catch_baslik"],
        icerik: texts["save_catch_icerik"] + e.toString(),
        anaButonYazisi: texts["save_catch_anaButonYazisi"],
      ).goster(context);
    }
    await PlatformDuyarliAlertDialog(
      baslik: texts["save_baslik"],
      icerik: texts["save_icerik"],
      anaButonYazisi: texts["save_anaButonYazisi"],
    ).goster(context);
    Navigator.pop(context, "saved");
  }

  Future<void> refreshLangTheme() async {
    try {
      var suan = DateTime.now();
      databaseHelper
          .updateSettingsNote(Note(0, "Language", "0", suan.toString(), 2));
      settings.lang = 0;

      databaseHelper.updateSettingsNote(
          Note(0, "Theme", "4293914607", suan.toString(), 2));
      settings.currentColor = Color(4293914607);
    } catch (e) {
      PlatformDuyarliAlertDialog(
        baslik: texts["refresh_catch_baslik"],
        icerik: texts["save_catch_icerik"] + e.toString(),
        anaButonYazisi: texts["save_catch_anaButonYazisi"],
      ).goster(context);
    }
    await PlatformDuyarliAlertDialog(
      baslik: texts["refresh_baslik"],
      icerik: texts["save_icerik"],
      anaButonYazisi: texts["save_anaButonYazisi"],
    ).goster(context);
    Navigator.pop(context, "refreshed");
  }
}
