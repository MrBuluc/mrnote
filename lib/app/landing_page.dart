import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mrnote/Login/login.dart';
import 'package:mrnote/common_widget/merkez_widget.dart';
import 'package:mrnote/models/notes.dart';
import 'package:mrnote/note_list.dart';
import 'package:mrnote/utils/database_helper.dart';
import 'package:path_provider/path_provider.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int lang, categoryID;
  Color currentColor;

  DatabaseHelper databaseHelper = DatabaseHelper();

  bool flag = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    read1().then((value) => flag = value);
  }

  @override
  Widget build(BuildContext context) {
    read();
    if (lang != null && currentColor != null) {
      if (flag) {
        return Login(
          lang,
          currentColor,
          categoryID,
        );
      } else {
        return NoteList(lang, currentColor, categoryID, true);
      }
    } else {
      return Scaffold(
        backgroundColor: Color(0xff84b7f1),
        body: MerkezWidget(
          children: [
            Image.asset(
              "assets/icon.png",
              height: 100,
              width: 100,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              "",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            CircularProgressIndicator(
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xfff1c984)),
            )
          ],
        ),
      );
    }
  }

  Future<void> read() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File("$path/language.txt");
    final file1 = File("$path/theme.txt");
    final file2 = File("$path/categoryID.txt");
    try {
      String contents = await file.readAsString();
      lang = int.parse(contents[10]);
    } catch (e) {
      file.writeAsString("language: 0");
      setState(() {});
    }
    try {
      String contents1 = await file1.readAsString();
      int color = int.parse(contents1.substring(35, 45));
      currentColor = Color(color);
      setState(() {});
    } catch (e) {
      file1.writeAsString("MaterialColor(primary value: Color(0xFFff0000))");
      setState(() {});
    }
    try {
      String contents = await file2.readAsString();
      categoryID = int.parse(contents[12]);
    } catch (e) {
      file2.writeAsString("CategoryID: 0");
      setState(() {});
    }
  }

  Future<bool> read1() async {
    List<Note> noteList =
        await databaseHelper.getNoteTitleNotesList("Password");
    String truePassword = noteList[0].noteContent;
    return truePassword != null && truePassword.isNotEmpty;
  }
}
