import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mrnote/Login/login.dart';
import 'package:mrnote/common_widget/merkez_widget.dart';
import 'package:path_provider/path_provider.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int lang;
  Color currentColor;

  @override
  Widget build(BuildContext context) {
    read();
    if (lang != null && currentColor != null) {
      return Login(
        lang: lang,
        color: currentColor,
      );
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
    try {
      String contents = await file.readAsString();
      lang = int.parse(contents[10]);

      String contents1 = await file1.readAsString();
      int color = int.parse(contents1.substring(35, 45));
      currentColor = Color(color);
      setState(() {});
    } catch (e) {
      file.writeAsString("language: 0");
      file1.writeAsString("MaterialColor(primary value: Color(0xFFff0000))");
      setState(() {});
    }
  }
}
