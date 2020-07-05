import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mrnote/note_list.dart';

//dosyaya ulaşmak için izin iste
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String password;
  String result = "";
  bool otomatikKontrol = false;
  String path =
      "/storage/emulated/0/Android/data/hakkicanbuluc.mrnote/Passwords/passwords.txt";
  bool check = false;

  @override
  void initState() {
    super.initState();
    fileCheck().then((value) => check = value);
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
            title: Text("Mr. Note Şifre ile Giriş"),
          ),
          body: Container(
            child: Center(heightFactor: 100,
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
                        hintText: check ? "Password" : "New Password",
                        hintStyle: TextStyle(fontSize: 12),
                        labelText: check ? "Your Password" : "New Your Password",
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (String value) => password = value,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RaisedButton(
                      child: Text(
                        "Şifemi Unuttum",
                        style: TextStyle(color: Colors.yellow),
                      ),
                      color: Colors.purple,
                      onPressed: () {
                        showPasswordPath();
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
    formKey.currentState.save();
    setState(() {
      result = "Logging In...";
    });
    File file = File(path);
    if (check) {
      String checkPassword = await file.readAsString();
      if (checkPassword == password) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NoteList()));
      }else{
        setState(() {
          result = "Password incorrect";
        });
      }
    }else{
      await file.create();
      await file.writeAsString(password);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NoteList()));
    }
  }

  Future<bool> fileCheck() async {
    File file = File(path);
    bool flag = await file.exists();
    return flag;
  }

  void showPasswordPath() {
    setState(() {
      result =
          "Your Password path: Android/data/hakkicanbuluc.mrnote/Passwords/passwords.txt";
    });
  }
}
