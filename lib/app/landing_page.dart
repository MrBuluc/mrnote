import 'package:flutter/material.dart';
import 'package:mrnote/Login/login.dart';
import 'package:mrnote/common_widget/merkez_widget.dart';
import 'package:mrnote/models/notes.dart';
import 'package:mrnote/note_list.dart';
import 'package:mrnote/utils/database_helper.dart';

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
        return NoteList(lang, currentColor, categoryID, false);
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
    try {
      List<Note> languageNoteList =
          await databaseHelper.getNoteTitleNotesList("Language");
      lang = int.parse(languageNoteList[0].noteContent);
    } catch (e) {
      lang = 0;
      setState(() {});
    }
    try {
      List<Note> themeNoteList =
      await databaseHelper.getNoteTitleNotesList("Theme");
      int color = int.parse(themeNoteList[0].noteContent);
      currentColor = Color(color);
      setState(() {});
    } catch (e) {
      currentColor = Color(0xFFff0000);
      setState(() {});
    }
    try {
      List<Note> categoryIDNoteList =
      await databaseHelper.getNoteTitleNotesList("CategoryID");
      categoryID = int.parse(categoryIDNoteList[0].noteContent);
    } catch (e) {
      categoryID = 0;
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
