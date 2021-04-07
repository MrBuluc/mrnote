import 'package:flutter/material.dart';
import 'package:mrnote/models/note.dart';
import 'package:mrnote/models/settings.dart';

import '../../const.dart';
import '../../services/database_helper.dart';
import '../Note_List/note_list.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  final formKey = GlobalKey<FormState>();

  String passwordStr, truePassword;
  String result = "";

  Note password;

  Map<String, String> texts;

  Map<String, String> english = {
    "Text1": "Enter the Password",
    "TextFormField_hintText": "Password",
    "RaisedButton_Text": "Reset",
    "Enter": "Enter",
    "result_enterTrue": "Logging In...",
    "result_enterFalse": "Wrong Password",
    "result_resetNull":
        "Press the Enter button after that\n" + "press the Reset button",
    "result_resetElse":
        "Password has been reset\n" + "You can enter the Mr. Note"
  };

  Map<String, String> turkish = {
    "Text1": "Parolanızı Giriniz",
    "TextFormField_hintText": "Parola",
    "RaisedButton_Text": "Sıfırla",
    "Enter": "Giriş",
    "result_enterTrue": "Giriş Yapılıyor...",
    "result_enterFalse": "Yanlış Parola",
    "result_resetNull":
        "Giriş butonuna basın sonra\n" + "Parolayı Sıfırla butonuna basın",
    "result_resetElse": "Parola sıfırlandı\n" + "Mr. Note a girebilirsiniz"
  };

  Settings settings = Settings();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    switch (settings.lang) {
      case 0:
        texts = english;
        break;
      case 1:
        texts = turkish;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: settings.currentColor,
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildHeader(),
                buildTextForm(size),
                buildResult(),
              ],
            )),
      ),
    );
  }

  buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(texts["Text1"], style: headerStyle3),
    );
  }

  Widget buildTextForm(Size size) {
    return Container(
      height: 200,
      width: 350,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3)),
          ]),
      child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30),
                child: TextFormField(
                  obscureText: true,
                  style: headerStyle4,
                  decoration: InputDecoration(
                    hintText: texts["TextFormField_hintText"],
                    prefixIcon: Icon(
                      Icons.lock,
                      color: generalColor,
                    ),
                  ),
                  onSaved: (String value) => passwordStr = value,
                ),
              ),
              buildSave()
            ],
          )),
    );
  }

  buildSave() {
    return Padding(
      padding: const EdgeInsets.only(right: 50.0, top: 30, left: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 40,
            width: 80,
            decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: GestureDetector(
                child: Text(
                  texts["RaisedButton_Text"],
                  style: headerStyle11,
                ),
                onTap: () {
                  resetThePassword();
                },
              ),
            ),
          ),
          Container(
            height: 40,
            width: 80,
            decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: GestureDetector(
                child: Text(
                  texts["Enter"],
                  style: headerStyle11,
                ),
                onTap: () {
                  enter();
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  buildResult() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        result,
        style: TextStyle(fontSize: 20),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> enter() async {
    password = await databaseHelper.getNoteIDNote(1);
    debugPrint("password: " + password.toString());
    truePassword = password.noteContent;
    if (truePassword == null) {
      truePassword = "";
    }

    formKey.currentState.save();
    setState(() {
      result = texts["result_enterTrue"];
    });

    if (passwordStr == truePassword) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => NoteList()));
    } else if (truePassword == "") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => NoteList()));
    } else {
      setState(() {
        result = texts["result_enterFalse"];
      });
    }
  }

  Future<void> resetThePassword() async {
    if (password == null) {
      setState(() {
        result = texts["result_resetNull"];
      });
    } else {
      password.noteContent = "";
      var suan = DateTime.now();
      await databaseHelper
          .updateSettingsNote(Note.withID(
              password.noteID,
              password.categoryID,
              password.noteTitle,
              password.noteContent,
              suan.toString(),
              password.notePriority))
          .then((value) {
        setState(() {
          result = texts["result_resetElse"];
        });
      });
    }
  }
}
