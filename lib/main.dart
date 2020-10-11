import 'package:flutter/material.dart';
import 'package:mrnote/Login/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Mr. Note",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.purple,
          primaryColor: Color(0xFFff0000),
          accentColor: Colors.orange),
      home: Login(),
    );
  }
}
