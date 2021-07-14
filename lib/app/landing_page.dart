import 'package:flutter/material.dart';
import 'package:mrnote/common_widget/merkez_widget.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/models/note.dart';
import 'package:mrnote/models/settings.dart';
import 'package:mrnote/ui/Login/login.dart';

import '../services/database_helper.dart';
import '../ui/Note_List/note_list.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  bool flag = false;

  String truePassword;

  Settings settings = Settings();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    read1().then((value) => flag = value);
    settings.getAdOpen();
  }

  @override
  Widget build(BuildContext context) {
    read();
    if (settings.lang != null && settings.currentColor != null) {
      if (flag) {
        return Login();
      } else {
        return NoteList();
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
      Note password = await databaseHelper.getNoteIDNote(1);
      if (password != null && password.categoryID == 1) {
        var suan = DateTime.now();
        await databaseHelper.addColumn("category", "categoryColor", "INTEGER");
        await databaseHelper
            .addNote(Note(0, "Language", "0", suan.toString(), 2));
        await databaseHelper
            .addNote(Note(0, "Theme", "4293914607", suan.toString(), 2));
        await databaseHelper
            .addNote(Note(0, "Sort", "3/1", suan.toString(), 2));
        await databaseHelper
            .addNote(Note(0, "Version", "2.0.0", suan.toString(), 2));
        await databaseHelper.deleteNote(1);
        await databaseHelper
            .addNote(Note.withID(1, 0, "Password", null, suan.toString(), 2));
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
    } catch (e) {
      debugPrint("read hata: " + e.toString());
    }
    try {
      List<Note> languageNoteList =
          await databaseHelper.getSettingsNoteTitleList("Language");
      settings.lang = int.parse(languageNoteList[0].noteContent);
    } catch (e) {
      settings.lang = 0;
    }
    try {
      List<Note> themeNoteList =
          await databaseHelper.getSettingsNoteTitleList("Theme");
      int color = int.parse(themeNoteList[0].noteContent);
      settings.currentColor = Color(color);
    } catch (e) {
      settings.currentColor = Color(4293914607);
    }
    setState(() {});
  }

  Future<bool> read1() async {
    Note password = await databaseHelper.getNoteIDNote(1);
    setState(() {
      truePassword = password.noteContent;
    });
    return truePassword != null && truePassword.isNotEmpty;
  }
}
