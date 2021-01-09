import 'dart:io';

import 'package:animations/animations.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:mrnote/category_operations.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/models/notes.dart';
import 'package:mrnote/note_detail.dart';
import 'package:mrnote/utils/database_helper.dart';
import 'package:path_provider/path_provider.dart';

import 'Settings/SettingsPage.dart';
import 'common_widget/platform_duyarli_alert_dialog.dart';

const double _fabDimension = 56.0;

class NoteList extends StatefulWidget {
  int lang, categoryID;
  Color color;

  NoteList(this.lang, this.color, this.categoryID);

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Category> allCategories;
  int localCategoryID = 0;

  InterstitialAd myInterstitialAd;

  Map<String, String> texts;

  Map<String, String> english = {
    "PopupMenuItem": "Categories =>",
    "PopupMenuItem1": "All Notes",
    "PopupMenuItem2": "Settings =>",
    "FloatingActionButton_tooltip": "Add Category",
    "FloatingActionButton1_title": "New Note",
    "addCategoryDialog_SimpleDialog_title": "Add Category",
    "addCategoryDialog_SimpleDialog_TextFormField_labelText": "Category Name",
    "addCategoryDialog_SimpleDialog_TextFormField_validator":
    "Please enter least 3 character",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton": "Cancel ❌",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1_SnackBar":
    "category successfully added 👌",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1": "Save 💾",
  };

  Map<String, String> turkish = {
    "PopupMenuItem": "Kategoriler =>",
    "PopupMenuItem1": "Tüm Notlar",
    "PopupMenuItem2": "Ayarlar =>",
    "FloatingActionButton_tooltip": "Kategori Ekle",
    "FloatingActionButton1_title": "Yeni Not",
    "addCategoryDialog_SimpleDialog_title": "Kategori Ekle",
    "addCategoryDialog_SimpleDialog_TextFormField_labelText": "Kategori Adı",
    "addCategoryDialog_SimpleDialog_TextFormField_validator":
    "Lütfen en az 3 karakter giriniz",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton": "İptal ❌",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1_SnackBar":
    "Kategori başarıyla eklendi 👌",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1": "Kaydet 💾",
  };

  ContainerTransitionType _transitionType = ContainerTransitionType.fade;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // AdmobHelper.admobInitialize();
    //     // myInterstitialAd = AdmobHelper.buildInterstitialAd();
    //     // myInterstitialAd
    //     //   ..load()
    //     //   ..show();
    localCategoryID = widget.categoryID;
  }

  @override
  void dispose() {
    //myInterstitialAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.lang) {
      case 0:
        texts = english;
        break;
      case 1:
        texts = turkish;
        break;
    }
    if (allCategories == null) {
      allCategories = List<Category>();
      updateCategoryList();
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: widget.color,
        title: Center(
          child: Text("Mr. Note"),
        ),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                    child: ListTile(
                      leading: Icon(
                        Icons.import_contacts,
                        color: Colors.blue,
                      ),
                      title: Text(
                        texts["PopupMenuItem"],
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        var result = await _goToPage(Categories(
                          widget.lang,
                          widget.color,
                        ));
                        if (result != null) {
                          setState(() {
                            updateCategoryList();
                          });
                        } else {
                          setState(() {});
                        }
                      },
                    )),
                PopupMenuItem(
                    child: ListTile(
                      leading: Icon(
                        Icons.import_contacts,
                        color: Colors.blue,
                      ),
                      title: Text(
                        texts["PopupMenuItem1"],
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () async {
                        setState(() {
                          localCategoryID = 0;
                        });
                        Navigator.pop(context);
                        setState(() {});
                      },
                    )),
                for (int index = 0; index < allCategories.length; index++)
                  PopupMenuItem(
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          localCategoryID = allCategories[index].categoryID;
                        });
                        saveCategoryID(localCategoryID);
                        Navigator.pop(context);
                        setState(() {});
                      },
                      title: Text(
                        allCategories[index].categoryTitle,
                        style: TextStyle(fontSize: 20),
                      ),
                      leading: Icon(
                        Icons.import_contacts,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                PopupMenuItem(
                    child: ListTile(
                      leading: Icon(
                        Icons.settings,
                        color: Colors.green,
                        size: 30,
                      ),
                      title: Text(
                        texts["PopupMenuItem2"],
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        var result = await _goToPage(SettingsPage(
                          widget.lang,
                          widget.color,
                        ));
                        if (result != null) {
                          setState(() {
                            widget.lang = int.parse(result[0]);
                            widget.color = Color(int.parse(result.substring(1)));
                          });
                        } else {
                          setState(() {});
                        }
                      },
                    ))
              ];
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              addCategoryDialog(context);
            },
            tooltip: texts["FloatingActionButton_tooltip"],
            child: Icon(Icons.import_contacts),
            mini: true,
          ),
          OpenContainer(
            onClosed: (result) {
              if (result != null) {
                setState(() {});
              }
            },
            transitionType: _transitionType,
            openBuilder: (BuildContext context, VoidCallback _) {
              return NoteDetail(
                texts["FloatingActionButton1_title"],
                widget.lang,
                widget.color,
              );
            },
            closedElevation: 6.0,
            closedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(_fabDimension / 2),
              ),
            ),
            closedColor: Theme.of(context).colorScheme.secondary,
            closedBuilder: (BuildContext context, VoidCallback openContainer) {
              return SizedBox(
                height: _fabDimension,
                width: _fabDimension,
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.onSecondary,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Notes(
        categoryID: localCategoryID,
        lang: widget.lang,
        color: widget.color,
      ),
    );
  }

  void addCategoryDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String newCategoryTitle;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              texts["addCategoryDialog_SimpleDialog_title"],
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: <Widget>[
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: texts[
                      "addCategoryDialog_SimpleDialog_TextFormField_labelText"],
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value.length < 3) {
                        return texts[
                            "addCategoryDialog_SimpleDialog_TextFormField_validator"];
                      } else
                        return null;
                    },
                    onSaved: (value) {
                      newCategoryTitle = value;
                    },
                  ),
                ),
              ),
              ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.orangeAccent,
                    child: Text(
                      texts[
                      "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton"],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        databaseHelper
                            .addCategory(Category(newCategoryTitle))
                            .then((value) {
                          if (value > 0) {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text(texts[
                              "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1_SnackBar"]),
                              duration: Duration(seconds: 2),
                            ));
                            Navigator.pop(context);
                            setState(() {
                              updateCategoryList();
                            });
                          }
                        });
                      }
                    },
                    color: Colors.redAccent,
                    child: Text(
                      texts[
                      "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1"],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  Future<String> _goToPage(Object page) async {
    final result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => page));
    return result;
  }

  void updateCategoryList() {
    databaseHelper.getCategoryList().then((categoryList) {
      setState(() {
        allCategories = categoryList;
      });
    });
  }

  Future<void> saveCategoryID(int localCategoryID) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File("$path/categoryID.txt");
      file.writeAsString("CategoryID: $localCategoryID");
    } catch (e) {
      PlatformDuyarliAlertDialog(
        baslik: texts["saveCategoryID_catch_baslik"],
        icerik: texts["saveCategoryID_catch_icerik"] + e.toString(),
        anaButonYazisi: texts["saveCategoryID_catch_anaButonYazisi"],
      ).goster(context);
    }
  }
}

class Notes extends StatefulWidget {
  int categoryID;
  int lang;
  Color color;

  Notes({this.categoryID, this.lang, this.color});

  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  List<Note> allNotes;
  DatabaseHelper databaseHelper;
  Color red = Color(0xFFff0000);

  Map<String, dynamic> texts;

  Map<String, dynamic> english = {
    "Padding": "Before create new note, you have to create new category",
    "Column_Row": "Category: ",
    "Column_Row1": "Creation Date: ",
    "Column_Padding": "Content",
    "Column_RaisedButton": "Open",
    "Column_RaisedButton1": "Delete",
    "NoteDetail": "Update Note",
    "Priority": ["Low", "Medium", "High"],
    "_delNote_if": "1 Mr. Note Deleted",
    "_delNote_else": "You can't delete Password Note",
    "_areYouSureforDelete_baslik": "Are you Sure?",
    "_areYouSureforDelete_icerik": "1 Mr. Note will be deleted.",
    "_areYouSureforDelete_anaButonYazisi": "DELETE",
    "_areYouSureforDelete_iptalButonYazisi": "CANCEL",
  };

  Map<String, dynamic> turkish = {
    "Padding": "Yeni Not oluşturmadan önce, yeni kategori oluşturmalısınız",
    "Column_Row": "Kategori: ",
    "Column_Row1": "Oluşturma Tarihi: ",
    "Column_Padding": "İçerik",
    "Column_RaisedButton": "Aç",
    "Column_RaisedButton1": "Sil",
    "NoteDetail": "Notu Güncelle",
    "Priority": ["Düşük", "Orta", "Yüksek"],
    "_delNote_if": "1 Mr. Not Silindi",
    "_delNote_else": "Parola Notunu silemezsiniz",
    "_areYouSureforDelete_baslik": "Emin misiniz?",
    "_areYouSureforDelete_icerik": "1 Mr. Note silinecek.",
    "_areYouSureforDelete_anaButonYazisi": "SİL",
    "_areYouSureforDelete_iptalButonYazisi": "İPTAL",
  };

  @override
  void initState() {
    super.initState();
    allNotes = List<Note>();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.lang) {
      case 0:
        texts = english;
        break;
      case 1:
        texts = turkish;
        break;
    }
    getFilterNotesList(widget.categoryID);
    return allNotes.length == 0
        ? Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          texts["Padding"],
          style: TextStyle(fontSize: 20),
        ),
      ),
    )
        : ListView.builder(
        itemCount: allNotes.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            leading: _setPriorityIcon(allNotes[index].notePriority),
            title: Text(
              allNotes[index].noteTitle,
              style: TextStyle(fontSize: 20),
            ),
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(4),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            texts["Column_Row"],
                            style: TextStyle(
                                color: Colors.black, fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            allNotes[index].categoryTitle,
                            style: TextStyle(color: red, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            texts["Column_Row1"],
                            style: TextStyle(
                                color: Colors.black, fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            databaseHelper.dateFormat(
                                DateTime.parse(allNotes[index].noteTime),
                                widget.lang),
                            style: TextStyle(color: red, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextFormField(
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: texts["Column_Padding"],
                            border: OutlineInputBorder(),
                          ),
                          initialValue: allNotes[index].noteContent,
                          readOnly: true,
                        )),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () async {
                            var result = await _goToDetailPage(
                                context, allNotes[index]);
                            if (result != null) {
                              setState(() {});
                            }
                          },
                          child: Text(
                            texts["Column_RaisedButton"],
                            style: TextStyle(
                                color: allNotes[index].notePriority == 2
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 20),
                          ),
                          color: _setBackgroundColor(
                              allNotes[index].notePriority),
                        ),
                        RaisedButton(
                          onPressed: () {
                            _areYouSureforDelete(allNotes[index].noteID);
                          },
                          child: Text(
                            texts["Column_RaisedButton1"],
                            style: TextStyle(
                                color: _setBackgroundColor(
                                    allNotes[index].notePriority),
                                fontSize: 20),
                          ),
                          color: allNotes[index].notePriority == 2
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          );
        });
  }

  Future<void> getFilterNotesList(int categoryID) async {
    if (categoryID == 0) {
      List<Note> allNotes1 = await databaseHelper.getNoteList();
      setState(() {
        allNotes = allNotes1;
      });
    } else {
      List<Note> allNotes1 =
      await databaseHelper.getCategoryNotesList(categoryID);
      setState(() {
        allNotes = allNotes1;
      });
    }
  }

  Future<String> _goToDetailPage(BuildContext context, Note note) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                NoteDetail(
                  texts["NoteDetail"],
                  widget.lang,
                  widget.color,
                  updateNote: note,
                )));
    return result;
  }

  _setPriorityIcon(int notePriority) {
    switch (notePriority) {
      case 0:
        return CircleAvatar(
          child: Text(
            texts["Priority"][0],
            style: TextStyle(color: Colors.black, fontSize: 13),
          ),
          backgroundColor: Colors.green,
        );
        break;
      case 1:
        return CircleAvatar(
          child: Text(
            texts["Priority"][1],
            style: TextStyle(color: Colors.black, fontSize: 10),
          ),
          backgroundColor: Colors.yellow,
        );
        break;
      case 2:
        return CircleAvatar(
            child: Text(
              texts["Priority"][2],
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            backgroundColor: red);
        break;
    }
  }

  _setBackgroundColor(int notePriority) {
    switch (notePriority) {
      case 0:
        return Colors.green;
        break;
      case 1:
        return Colors.yellow;
        break;
      case 2:
        return red;
        break;
    }
  }

  _delNote(int noteID) {
    databaseHelper.deleteNote(noteID).then((deletedID) {
      if (deletedID != 0) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(texts["_delNote_if"]),
        ));

        setState(() {});
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(texts["_delNote_else"]),
        ));
      }
    });
  }

  Future<void> _areYouSureforDelete(int noteID) async {
    final sonuc = await PlatformDuyarliAlertDialog(
      baslik: texts["_areYouSureforDelete_baslik"],
      icerik: texts["_areYouSureforDelete_icerik"],
      anaButonYazisi: texts["_areYouSureforDelete_anaButonYazisi"],
      iptalButonYazisi: texts["_areYouSureforDelete_iptalButonYazisi"],
    ).goster(context);

    if (sonuc) {
      _delNote(noteID);
    }
  }
}
