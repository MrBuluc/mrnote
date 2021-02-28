import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:mrnote/common_widget/build_note_list.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/utils/database_helper.dart';

import 'const.dart';
import 'models/note.dart';
import 'utils/admob_helper.dart';

class Category_Page extends StatefulWidget {
  Category category;
  int lang;
  Color color;
  bool adOpen;

  Category_Page(this.category, this.lang, this.color, this.adOpen);

  @override
  _Category_PageState createState() => _Category_PageState();
}

class _Category_PageState extends State<Category_Page> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  InterstitialAd myInterstitialAd;

  Map<String, String> texts;

  Map<String, String> english = {
    "notes": "Mr. Notes",
    "Padding": "It looks a bit cold around here 🥶\n" + "Let's warm it up 🥳",
  };

  Map<String, String> turkish = {
    "notes": "Mr. Notlar",
    "Padding": "Buralar soğuk gözüküyor 🥶\n" + "Hadi biraz ısıtalım 🥳",
  };

  Color currentColor;

  Category category;

  List<Note> allNotes;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.adOpen) {
      adInitialize();
    }
    switch (widget.lang) {
      case 0:
        texts = english;
        break;
      case 1:
        texts = turkish;
        break;
    }
    currentColor = widget.color;
    category = widget.category;
    allNotes = List<Note>();
  }

  @override
  void dispose() {
    if (widget.adOpen) {
      disposeAd();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    fillAllNotes();
    return SafeArea(
      child: Scaffold(
        backgroundColor: scaffoldColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              buildHeader(size),
              SizedBox(
                height: 20,
              ),
              allNotes.length == 0
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          texts["Padding"],
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    )
                  : Container(
                      height: 150.0 * allNotes.length,
                      child: BuildNoteList(
                        widget.lang,
                        size,
                        widget.color,
                        widget.adOpen,
                        null,
                        category: category,
                      )),
            ],
          ),
        ),
      ),
    );
  }

  void adInitialize() {
    AdmobHelper.admobInitialize();
    myInterstitialAd = AdmobHelper.buildInterstitialAd();
    myInterstitialAd
      ..load()
      ..show();
  }

  void disposeAd() {
    myInterstitialAd.dispose();
  }

  Future<void> fillAllNotes() async {
    List<Note> allNotes1;
    if (category.categoryID == 0) {
      allNotes1 = await databaseHelper.getNoteList();
    } else {
      allNotes1 =
      await databaseHelper.getCategoryNotesList(category.categoryID);
    }
    allNotes1.sort();
    setState(() {
      allNotes = allNotes1;
    });
  }

  Widget buildHeader(Size size) {
    return Container(
      height: 220,
      color: Color(category.categoryColor),
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5, top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Colors.white,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Text(
              category.categoryTitle,
              style: headerStyle6,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "${allNotes.length} ${texts["notes"]}",
                style: headerStyle7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
