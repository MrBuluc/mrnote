import 'package:flutter/material.dart';
import 'package:mrnote/models/notes.dart';
import 'package:mrnote/note_list.dart';
import 'package:mrnote/utils/database_helper.dart';

class Login extends StatefulWidget {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //AdmobHelper.admobInitialize();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
            accentColor: Colors.green,
            hintColor: Colors.indigo,
            errorColor: Colors.red,
            primaryColor: Colors.teal),
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
            title: Text("Mr. Note Enter the Password"),
          ),
          body: Container(
            child: Center(
              heightFactor: 100,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 200, 10, 10),
                child: Form(
                  key: formKey,
                  child: ListView(children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        hintText: "Password",
                        hintStyle: TextStyle(fontSize: 12),
                        labelText: "Your Password",
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (String value) => password = value,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RaisedButton(
                      child: Text(
                        "Reset The Password",
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
      result = "Logging In...";
    });

    if (password == truePassword) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => NoteList()));
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => NoteList()));
    } else {
      setState(() {
        result = "Wrong Password";
      });
    }
  }

  Future<void> resetThePassword() async {
    if (note == null) {
      setState(() {
        result =
            "Press the Enter button after that\n" + "press the Reset button";
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
            result = "Password has been reset\n" + "You can enter the Mr. Note";
          });
        }
      });
    }
  }
}
