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

  @override
  Widget build(BuildContext context) {
    read();
    if (lang != null) {
      return Login(
        lang: lang,
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
    final file = File("$path/settings.txt");
    try {
      String contents = await file.readAsString();
      lang = int.parse(contents[10]);
      setState(() {});
    } catch (e) {
      file.writeAsString("language: 0");
      setState(() {});
    }
  }
}
