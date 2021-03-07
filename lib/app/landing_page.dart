import 'package:flutter/material.dart';
import 'package:mrnote/Login/login.dart';
import 'package:mrnote/common_widget/merkez_widget.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/models/note.dart';
import 'package:mrnote/note_list.dart';
import 'package:mrnote/utils/database_helper.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int lang;
  Color currentColor;

  DatabaseHelper databaseHelper = DatabaseHelper();

  bool flag = false;

  String truePassword;

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
        );
      } else {
        return NoteList(lang, currentColor, true);
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
    List<Note> noteList =
        await databaseHelper.getNoteTitleNotesList("Password");
    Note passwordNote = noteList[0];
    if (passwordNote.categoryID == 1) {
      var suan = DateTime.now();
      await databaseHelper
          .addNote(Note(0, "Language", "0", suan.toString(), 2));
      await databaseHelper
          .addNote(Note(0, "Theme", "4293914607", suan.toString(), 2));
      await databaseHelper.addNote(Note(0, "Sort", "3/1", suan.toString(), 2));
      await databaseHelper
          .addNote(Note(0, "Version", "2.0.0", suan.toString(), 2));
      await databaseHelper.updateNote(Note.withID(
          1, 0, "Password", passwordNote.noteContent, suan.toString(), 2));
      await databaseHelper.addColumn("category", "categoryColor", "INTEGER");
      await databaseHelper
          .updateCategory(Category.withID(1, "General", 4289760505));
      await databaseHelper
          .updateCategory(Category.withID(2, "Sport", 4288865453));
      await databaseHelper
          .updateCategory(Category.withID(3, "Family", 4294550692));
      await databaseHelper
          .updateCategory(Category.withID(4, "Job", 4292079355));
      await databaseHelper
          .updateCategory(Category.withID(5, "School", 4294819839));
    }
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
  }

  Future<bool> read1() async {
    List<Note> noteList =
        await databaseHelper.getNoteTitleNotesList("Password");
    truePassword = noteList[0].noteContent;
    return truePassword != null && truePassword.isNotEmpty;
  }
}
