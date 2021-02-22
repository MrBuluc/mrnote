import 'package:flutter/material.dart';
import 'package:mrnote/models/notes.dart';
import 'package:mrnote/note_list.dart';
import 'package:mrnote/utils/database_helper.dart';

import '../const.dart';

class Login extends StatefulWidget {
  int lang, categoryID;
  Color color;

  Login(this.lang, this.color, this.categoryID);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  final formKey = GlobalKey<FormState>();

  String password, truePassword;
  String result = "";

  Note note;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: widget.color,
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
                  onSaved: (String value) => password = value,
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
    List<Note> noteList =
    await databaseHelper.getNoteTitleNotesList("Password");
    truePassword = noteList[0].noteContent;
    if (truePassword == null) {
      truePassword = "";
    }
    note = noteList[0];

    formKey.currentState.save();
    setState(() {
      result = texts["result_enterTrue"];
    });

    if (password == truePassword) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => NoteList(
                  widget.lang, widget.color, widget.categoryID, false)));
    } else {
      setState(() {
        result = texts["result_enterFalse"];
      });
    }
  }

  Future<void> resetThePassword() async {
    if (note == null) {
      setState(() {
        result = texts["result_resetNull"];
      });
    } else {
      note.noteContent = "";
      var suan = DateTime.now();
      await databaseHelper
          .updateNote(Note.withID(note.noteID, note.categoryID, note.noteTitle,
          note.noteContent, suan.toString(), note.notePriority))
          .then((updatedID) {
        if (updatedID != 0) {
          setState(() {
            result = texts["result_resetElse"];
          });
        }
      });
    }
  }
}
