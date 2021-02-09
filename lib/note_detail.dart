import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/models/notes.dart';
import 'package:mrnote/utils/database_helper.dart';

import 'utils/admob_helper.dart';

class NoteDetail extends StatefulWidget {
  String title;
  Note updateNote;
  int lang;
  Color color;
  bool adOpen;

  NoteDetail(this.title, this.lang, this.color, this.adOpen, {this.updateNote});

  @override
  _NoteDetailState createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  var formkey = GlobalKey<FormState>();
  List<Category> allCategories;
  DatabaseHelper databaseHelper;
  int categoryID;
  int selectedPriority;
  String noteTitle, noteContent;

  InterstitialAd myInterstitialAd;

  Map<String, String> texts;

  Map<String, String> english = {
    "_priority0": "Low",
    "_priority1": "Medium",
    "_priority2": "High",
    "Container_Padding": "Category :",
    "Container_Padding1_hintText": "Enter Mr. Note Title",
    "Container_Padding2_hintText": "Enter Mr. Note Content",
    "Container_Padding2_labelText": "Mr. Note Content",
    "Container_Row": "Priority :",
    "Container_RaisedButton1": "Save",
  };

  Map<String, String> turkish = {
    "_priority0": "Düşük",
    "_priority1": "Orta",
    "_priority2": "Yüksek",
    "Container_Padding": "Kategori :",
    "Container_Padding1_hintText": "Mr. Notun Başlığını Girin",
    "Container_Padding2_hintText": "Mr. Notun İçeriğini Girin",
    "Container_Padding2_labelText": "Mr. Not İçeriği",
    "Container_Row": "Öncelik :",
    "Container_RaisedButton1": "Kaydet",
  };

  TextEditingController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allCategories = List<Category>();
    databaseHelper = DatabaseHelper();
    databaseHelper.getCategories().then((value) {
      for (Map readMap in value) {
        allCategories.add(Category.fromMap(readMap));
      }
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
    _controller = TextEditingController();
    _controller.text =
        widget.updateNote != null ? widget.updateNote.noteTitle : "";
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
    var _priority = [
      texts["_priority0"],
      texts["_priority1"],
      texts["_priority2"],
    ];
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: texts["Container_Padding1_hintText"],
          ),
        ),
        backgroundColor: widget.color,
        actions: [
          FlatButton(
            color: Colors.red.shade600,
            textColor: Colors.black,
            child: Text(
              texts["Container_RaisedButton1"],
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              save(context);
            },
          )
        ],
      ),
      body: allCategories.length <= 0
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                child: Form(
                  key: formkey,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              texts["Container_Padding"],
                              style:
                                  TextStyle(fontSize: 20, color: Colors.purple),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 12),
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 2),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                items: createCategoryItem(),
                                value: categoryID,
                                onChanged: (selectedCategoryID) {
                                  setState(() {
                                    categoryID = selectedCategoryID;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              texts["Container_Row"],
                              style: TextStyle(
                                  fontSize: 20, color: Color(0xFFff0000)),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 12),
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 2),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                items: _priority.map((e) {
                                  return DropdownMenuItem<int>(
                                    child: Text(
                                      e,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    value: _priority.indexOf(e),
                                  );
                                }).toList(),
                                value: selectedPriority,
                                onChanged: (selectedPriorityID) {
                                  setState(() {
                                    selectedPriority = selectedPriorityID;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextFormField(
                          initialValue: widget.updateNote != null
                              ? widget.updateNote.noteContent
                              : "",
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: texts["Container_Padding2_hintText"],
                            labelText: texts["Container_Padding2_labelText"],
                            border: OutlineInputBorder(),
                          ),
                          onSaved: (text) {
                            noteContent = text;
                          },
                        ),
                      ),
                    ],
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
    _controller.dispose();
  }

  List<DropdownMenuItem<int>> createCategoryItem() {
    return allCategories
        .map((category) => DropdownMenuItem<int>(
              value: category.categoryID,
              child: Text(
                category.categoryTitle,
                style: TextStyle(fontSize: 20),
              ),
            ))
        .toList();
  }

  void save(BuildContext context) {
    formkey.currentState.save();
    noteTitle = _controller.text;
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
}
