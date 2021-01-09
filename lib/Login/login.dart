import 'package:flutter/material.dart';
import 'package:mrnote/models/notes.dart';
import 'package:mrnote/note_list.dart';
import 'package:mrnote/utils/database_helper.dart';

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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String password, truePassword;
  String result = "";

  Note note;

  Map<String, String> texts;

  Map<String, String> english = {
    "Text1": "Enter the Password",
    "TextFormField_hintText": "Password",
    "TextFormField_labelText": "Your Password",
    "RaisedButton_Text": "Reset The Password",
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
    "TextFormField_labelText": "Parolanız",
    "RaisedButton_Text": "Parolayı Sıfırla",
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
    return Theme(
        data: Theme.of(context).copyWith(
          accentColor: Colors.green,
          hintColor: Colors.indigo,
          errorColor: Colors.red,
        ),
        child: Scaffold(
          key: _scaffoldKey,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              enter();
            },
            backgroundColor: Colors.teal,
            child: Icon(Icons.arrow_forward),
          ),
          appBar: AppBar(
            title: Center(child: Text("Mr. Note")),
            backgroundColor: widget.color,
          ),
          body: Container(
            child: Center(
              heightFactor: 100,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 200, 10, 10),
                child: Form(
                  key: formKey,
                  child: ListView(children: <Widget>[
                    Center(
                        child: Text(
                      texts["Text1"],
                      style: TextStyle(fontSize: 20),
                    )),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        hintText: texts["TextFormField_hintText"],
                        hintStyle: TextStyle(fontSize: 12),
                        labelText: texts["TextFormField_labelText"],
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (String value) => password = value,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RaisedButton(
                      child: Text(
                        texts["RaisedButton_Text"],
                        style: TextStyle(color: Colors.yellow),
                      ),
                      color: Colors.purple,
                      onPressed: () {
                        resetThePassword();
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        result,
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ]),
                ),
              ),
            ),
          ),
        ));
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
                widget.lang,
                    widget.color,
                    widget.categoryID,
                  )));
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
      note.noteContent = null;
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
