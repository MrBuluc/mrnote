import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/utils/database_helper.dart';

import 'const.dart';
import 'models/note.dart';
import 'utils/admob_helper.dart';

class NoteDetail extends StatefulWidget {
  Note updateNote;
  int lang;
  Color color;
  bool adOpen;

  NoteDetail(this.lang, this.color, this.adOpen, {this.updateNote});

  @override
  _NoteDetailState createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  var formKey = GlobalKey<FormState>();
  List<Category> allCategories;
  DatabaseHelper databaseHelper;
  int categoryID, selectedPriority;
  String noteTitle, noteContent;

  InterstitialAd myInterstitialAd;

  Map<String, String> texts;

  Map<String, String> english = {
    "_priority0": "Low",
    "_priority1": "Medium",
    "_priority2": "High",
    "Container_Padding1_hintText": "Enter Mr. Note Title",
    "Container_Padding2_hintText": "Enter Mr. Note Content",
  };

  Map<String, String> turkish = {
    "_priority0": "Düşük",
    "_priority1": "Orta",
    "_priority2": "Yüksek",
    "Container_Padding1_hintText": "Mr. Notun Başlığını Girin",
    "Container_Padding2_hintText": "Mr. Notun İçeriğini Girin",
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allCategories = List<Category>();
    databaseHelper = DatabaseHelper();
    databaseHelper.getCategoryList().then((value) {
      allCategories = value;
      if (widget.updateNote != null) {
        categoryID = widget.updateNote.categoryID;
        selectedPriority = widget.updateNote.notePriority;
      } else {
        categoryID = allCategories[0].categoryID;
        selectedPriority = 0;
      }
      setState(() {});
    });
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
    Size size = MediaQuery.of(context).size;
    var _priority = [
      texts["_priority0"],
      texts["_priority1"],
      texts["_priority2"],
    ];
    return SafeArea(
      child: SafeArea(
        child: Scaffold(
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                save(context);
              },
              backgroundColor: Colors.white,
              elevation: 5,
              child: Icon(
                Icons.save,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          backgroundColor: widget.color,
          body: allCategories.length <= 0
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Container(
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          buildAppBar(size, _priority),
                          buildTitleFormField(size),
                          buildFormField(size),
                        ],
                      ),
                    ),
                  ),
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

  void save(BuildContext context) {
    formKey.currentState.save();
    var suan = DateTime.now();
    if (widget.updateNote == null) {
      databaseHelper
          .addNote(Note(categoryID, noteTitle, noteContent, suan.toString(),
              selectedPriority))
          .then((savedNoteID) {
        if (savedNoteID != 0) {
          Navigator.pop(context, "saved");
        }
      });
    } else {
      databaseHelper
          .updateNote(Note.withID(widget.updateNote.noteID, categoryID,
              noteTitle, noteContent, suan.toString(), selectedPriority))
          .then((updatedID) {
        if (updatedID != 0) {
          Navigator.pop(context, "updated");
        }
      });
    }
  }

  Widget buildAppBar(Size size, List<String> priority) {
    return Container(
      height: 50,
      width: size.width,
      color: Colors.grey.shade100,
      child: Row(
        children: [
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.close,
                size: 40,
                color: Colors.grey.shade400,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(
            width: size.width * 0.25,
          ),
          dropDown(),
          SizedBox(
            width: size.width * 0.05,
          ),
          dropDownPriorty(priority)
        ],
      ),
    );
  }

  Widget dropDown() {
    return DropdownButton(
      value: categoryID,
      icon: Icon(Icons.keyboard_arrow_down),
      iconSize: 20,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.transparent,
      ),
      onChanged: (selectedCategoryID) {
        setState(() {
          categoryID = selectedCategoryID;
        });
      },
      items: createCategoryItem(),
    );
  }

  List<DropdownMenuItem<int>> createCategoryItem() {
    return allCategories
        .map((category) => DropdownMenuItem<int>(
              value: category.categoryID,
              child: Text(
                category.categoryTitle,
                style: headerStyle3,
              ),
            ))
        .toList();
  }

  Widget dropDownPriorty(List<String> priority) {
    return DropdownButton<int>(
      value: selectedPriority,
      icon: Icon(Icons.keyboard_arrow_down),
      iconSize: 20,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        color: Colors.transparent,
      ),
      onChanged: (selectedPriorityID) {
        setState(() {
          selectedPriority = selectedPriorityID;
        });
      },
      items: priority.map((e) {
        return DropdownMenuItem<int>(
          child: Text(
            e,
            style: headerStyle3_1,
          ),
          value: priority.indexOf(e),
        );
      }).toList(),
    );
  }

  Widget buildTitleFormField(Size size) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 5),
      child: TextFormField(
        initialValue:
            widget.updateNote != null ? widget.updateNote.noteTitle : "",
        maxLines: null,
        style: headerStyle5,
        cursorColor: Colors.grey.shade600,
        decoration: new InputDecoration(
          hintText: texts["Container_Padding1_hintText"],
          hintStyle: headerStyle5,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
        onSaved: (text) {
          noteTitle = text;
        },
      ),
    );
  }

  buildFormField(Size size) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Column(
        children: [
          TextFormField(
            initialValue:
                widget.updateNote != null ? widget.updateNote.noteContent : "",
            maxLines: null,
            style: headerStyle10,
            cursorColor: Colors.grey.shade800,
            decoration: InputDecoration(
              hintText: texts["Container_Padding2_hintText"],
              hintStyle: headerStyle10,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
            onSaved: (text) {
              noteContent = text;
            },
          )
        ],
      ),
    );
  }
}
