import 'package:animations/animations.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/models/notes.dart';
import 'package:mrnote/note_detail.dart';
import 'package:mrnote/utils/database_helper.dart';

import 'Settings/SettingsPage.dart';
import 'common_widget/platform_duyarli_alert_dialog.dart';
import 'const.dart';
import 'notification_handler.dart';
import 'utils/admob_helper.dart';

class NoteList extends StatefulWidget {
  int lang, categoryID;
  Color color;
  bool adOpen;

  NoteList(this.lang, this.color, this.categoryID, this.adOpen);

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Category> allCategories;
  int localCategoryID = 0;

  InterstitialAd myInterstitialAd, myInterstitialAdExit;

  Map<String, String> texts;

  Map<String, String> english = {
    "Home": "Home",
    "PopupMenuItem": "Categories",
    "PopupMenuItem1": "All Notes",
    "FloatingActionButton_tooltip": "+New",
    "addCategoryDialog_SimpleDialog_title": "Add Category",
    "addCategoryDialog_SimpleDialog_TextFormField_labelText": "Category Name",
    "addCategoryDialog_SimpleDialog_TextFormField_validator":
        "Please enter least 3 character",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton": "Cancel ❌",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1_SnackBar":
        "category successfully added 👌",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1": "Save 💾",
    //"FloatingActionButton1_title": "New Note",
    "saveCategoryID_catch_baslik": "Save Failed ❌",
    "save_catch_icerik": "Error: ",
    "save_catch_anaButonYazisi": "Ok",
    "_areYouSureforDelete_baslik": "Are you Sure?",
    "_areYouSureforDelete_icerik": "Are you sure for exit to Mr. Note?",
    "_areYouSureforDelete_anaButonYazisi": "EXIT",
    "_areYouSureforDelete_iptalButonYazisi": "CANCEL",
  };

  Map<String, String> turkish = {
    "Home": "Ana Sayfa",
    "PopupMenuItem": "Kategoriler",
    "PopupMenuItem1": "Tüm Notlar",
    "FloatingActionButton_tooltip": "+Yeni",
    "FloatingActionButton1_title": "Yeni Not",
    "addCategoryDialog_SimpleDialog_title": "Kategori Ekle",
    "addCategoryDialog_SimpleDialog_TextFormField_labelText": "Kategori Adı",
    "addCategoryDialog_SimpleDialog_TextFormField_validator":
    "Lütfen en az 3 karakter giriniz",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton": "İptal ❌",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1_SnackBar":
    "Kategori başarıyla eklendi 👌",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1": "Kaydet 💾",
    "save_catch_baslik": "Kaydetme Başarısız Oldu ❌",
    "save_catch_icerik": "Hata: ",
    "save_catch_anaButonYazisi": "Tamam",
    "_areYouSureforDelete_baslik": "Emin misiniz?",
    "_areYouSureforDelete_icerik":
        "Mr. Not dan çıkmak istediğinizden emin misiniz?",
    "_areYouSureforDelete_anaButonYazisi": "ÇIK",
    "_areYouSureforDelete_iptalButonYazisi": "İPTAL",
  };

  ContainerTransitionType _transitionType = ContainerTransitionType.fade;

  bool adOpen;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.adOpen) {
      adInitialize();
    }
    localCategoryID = widget.categoryID;
    adOpen = widget.adOpen;
    NotificationHandler().initializeFCMNotification(context);
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
    var size = MediaQuery
        .of(context)
        .size;
    return WillPopScope(
      onWillPop: () {
        return _areYouSureforExit();
      },
      child: SafeArea(
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: widget.color,
            body: ListView(
              children: <Widget>[
                SizedBox(
                  height: 25,
                ),
                header(size),
                categoriesAndNew(),
              ],
            )),
      ),
    );
  }

  void adInitialize() {
    AdmobHelper.admobInitialize();
    myInterstitialAd = AdmobHelper.buildInterstitialAd();
    myInterstitialAd
      ..load()
      ..show();
    myInterstitialAdExit = AdmobHelper.buildInterstitialAd();
    myInterstitialAdExit..load();
  }

  void disposeAd() {
    myInterstitialAd.dispose();
    myInterstitialAdExit.dispose();
  }

  Widget header(Size size) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(texts["Home"], style: headerStyle),
          GestureDetector(
            child: Icon(
              Icons.settings,
              color: Colors.grey.shade800,
              size: 30,
            ),
            onTap: () async {
              var result = await _goToPage(SettingsPage(
                widget.lang,
                widget.color,
                adOpen,
              ));
              if (result != null) {
                List<String> resultList = result.split("/");

                if (resultList.elementAt(2) == "0") {
                  setState(() {
                    adOpen = false;
                  });
                } else {
                  setState(() {
                    adOpen = true;
                  });
                }
                setState(() {
                  widget.lang = int.parse(resultList.elementAt(0));
                  widget.color = Color(int.parse(resultList.elementAt(1)));
                  widget.adOpen = adOpen;
                });
              } else {
                setState(() {});
              }
            },
          )
        ],
      ),
    );
  }

  Widget categoriesAndNew() {
    return Container(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 30, top: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              texts["PopupMenuItem"],
              style: headerStyle2,
            ),
            GestureDetector(
              child: Text(
                texts["FloatingActionButton_tooltip"],
                style: headerStyle3,
              ),
              onTap: () {
                addCategoryDialog(context);
              },
            ),
          ],
        ),
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
      categoryList.add(Category.withID(0, texts["PopupMenuItem1"]));
      setState(() {
        allCategories = categoryList;
      });
    });
  }

  Future<void> saveCategoryID(int localCategoryID) async {
    try {
      var suan = DateTime.now();
      databaseHelper.updateNote(Note.withID(
          4, 0, "CategoryID", localCategoryID.toString(), suan.toString(), 2));
    } catch (e) {
      PlatformDuyarliAlertDialog(
        baslik: texts["saveCategoryID_catch_baslik"],
        icerik: texts["saveCategoryID_catch_icerik"] + e.toString(),
        anaButonYazisi: texts["saveCategoryID_catch_anaButonYazisi"],
      ).goster(context);
    }
  }

  Future<bool> _areYouSureforExit() async {
    final sonuc = await PlatformDuyarliAlertDialog(
      baslik: texts["_areYouSureforDelete_baslik"],
      icerik: texts["_areYouSureforDelete_icerik"],
      anaButonYazisi: texts["_areYouSureforDelete_anaButonYazisi"],
      iptalButonYazisi: texts["_areYouSureforDelete_iptalButonYazisi"],
    ).goster(context);

    if (sonuc && widget.adOpen) {
      return showAd();
    }
    return Future.value(true);
  }

  Future<bool> showAd() async {
    myInterstitialAdExit..show();
    return Future.value(true);
  }
}

class Notes extends StatefulWidget {
  int categoryID;
  int lang;
  Color color;
  bool adOpen;

  Notes(this.adOpen, {this.categoryID, this.lang, this.color});

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
    List<Note> allNotes1;
    if (categoryID == 0) {
      allNotes1 = await databaseHelper.getNoteList();
    } else {
      allNotes1 = await databaseHelper.getCategoryNotesList(categoryID);
    }
    allNotes1.sort();
    setState(() {
      allNotes = allNotes1;
    });
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
                  widget.adOpen,
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
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(texts["_delNote_if"]),
      ));

      setState(() {});
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
