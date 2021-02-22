import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:mrnote/common_widget/platform_duyarli_alert_dialog.dart';
import 'package:mrnote/models/notes.dart';
import 'package:mrnote/utils/admob_helper.dart';
import 'package:mrnote/utils/database_helper.dart';

import '../const.dart';

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
    "Currently_Password": "Currently Password:",
    // "AlertDialog": 'Select a color',
    // "RaisedButtonText": "Select Color",
    // "Container_Padding2": "Current Password:",
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
    "Currently_Password": "Şuanki Parola:",
    "AlertDialog": 'Bir Renk Seçin',
    "RaisedButtonText": "Renk Seç",
    "Container_Padding2": "Mevcut Şifre:",
    "password_save_baslik": "Parolayı Kaldırmak İstiyor Musunuz?",
    "password_save_icerik": "Bu işlemi onaylarsanız şifre kaldırılacaktır.",
    "password_save_anaButonYazisi": "Onayla",
    "password_save_iptalButonYazisi": "İptal",
  };

  Color currentColor;

  bool adOpen, show = false;

  double ekranYuksekligi, ekranGenisligi;

  String gelistiriciSayfasiParola,
      password = "",
      newPassword,
      showPassword = "";

  DatabaseHelper databaseHelper = DatabaseHelper();

  List<String> bos = [""];

  final myController = TextEditingController();

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
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
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
              height: 20,
            ),
            dropDownButtonsColumn(),
            currentPassword(),
            SizedBox(
              height: 10,
            ),
            changePassword(bos, texts["Change Your Password"], size),
            saveButton(),
            // GestureDetector(
            //   child: Container(
            //     color: Colors.white,
            //     child: SizedBox(
            //       width: ekranGenisligi,
            //       height: ekranYuksekligi - 332,
            //     ),
            //   ),
            //   onLongPress: () async {
            //     final sonuc = await _showMyDialog();
            //     if (sonuc) {
            //       gelistiriciSayfasiGiris();
            //     }
            //   },
            // )
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
    List<Note> noteList =
    await databaseHelper.getNoteTitleNotesList("Password");
    setState(() {
      password = noteList[0].noteContent;
    });
    if (password != "" || password != null) {
      prepareShowPassword();
    }
  }

  void prepareShowPassword() {
    setState(() {
      showPassword = "*" * (password.length);
    });
  }

  Widget buildHeader(Size size) {
    return Container(
      height: 220,
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
    );
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
                value: widget.lang,
                onChanged: (selectedLang) {
                  setState(() {
                    widget.lang = selectedLang;
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
        .map((lang) =>
        DropdownMenuItem<int>(
          value: langList.indexOf(lang),
          child: Text(
            lang,
            style: headerStyle7,
          ),
        ))
        .toList();
  }

  Widget currentPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            texts["Currently_Password"],
            style: headerStyle7,
          ),
        ),
        Text(
          show ? password : showPassword,
          style: TextStyle(fontSize: 20),
        ),
        password != ""
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
                Icons.save,
                color: Colors.white,
                size: 30,
              ),
            ),
            onTap: () {
              save(widget.lang, widget.color, adOpen);
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
          databaseHelper.updateNote(
              Note.withID(1, 0, "Password", newPassword, suan.toString(), 2));
        }
      } else {
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
      Navigator.pop(context);
    }
  }

  Future<void> save(int lang, Color color, bool adOpen) async {
    try {
      var suan = DateTime.now();
      databaseHelper.updateNote(
          Note.withID(2, 0, "Language", lang.toString(), suan.toString(), 2));

      databaseHelper.updateNote(Note.withID(
          3, 0, "Theme", color.value.toString(), suan.toString(), 2));
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

  // Future<bool> _showMyDialog() async {
  //   return showDialog<bool>(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text("Geliştirici Sayfası Giriş"),
  //           content: Form(
  //             key: formKey,
  //             child: TextFormField(
  //               obscureText: true,
  //               decoration: InputDecoration(
  //                 hintText: "Parola",
  //                 prefixIcon: Icon(
  //                   Icons.lock,
  //                 ),
  //               ),
  //               onSaved: (String value) => gelistiriciSayfasiParola = value,
  //             ),
  //           ),
  //           actions: <Widget>[
  //             FlatButton(
  //               child: Text(
  //                 "Iptal",
  //                 style: TextStyle(fontSize: 20),
  //               ),
  //               onPressed: () {
  //                 Navigator.of(context).pop(false);
  //               },
  //             ),
  //             FlatButton(
  //               child: Text(
  //                 "Onayla",
  //                 style: TextStyle(fontSize: 20),
  //               ),
  //               onPressed: () {
  //                 Navigator.of(context).pop(true);
  //               },
  //             )
  //           ],
  //         );
  //       });
  // }
  //
  // Future<void> gelistiriciSayfasiGiris() async {
  //   formKey.currentState.save();
  //   if (gelistiriciSayfasiParola == "Hakkican99") {
  //     var result = await _goToPage(DeveloperPage(widget.adOpen));
  //     if (result != null) {
  //       if (result == "0") {
  //         setState(() {
  //           adOpen = false;
  //         });
  //       } else {
  //         adInitialize();
  //         setState(() {
  //           adOpen = true;
  //         });
  //       }
  //       setState(() {
  //         widget.adOpen = adOpen;
  //       });
  //     } else {
  //       setState(() {});
  //     }
  //   }
  // }

  Future<String> _goToPage(Object page) async {
    final result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => page));
    return result;
  }
}
