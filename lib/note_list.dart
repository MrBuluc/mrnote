import 'package:animations/animations.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/models/note.dart';
import 'package:mrnote/note_detail.dart';
import 'package:mrnote/utils/database_helper.dart';

import 'Settings/SettingsPage.dart';
import 'category_page.dart';
import 'common_widget/build_note_list.dart';
import 'common_widget/platform_duyarli_alert_dialog.dart';
import 'const.dart';
import 'notification_handler.dart';
import 'search_page.dart';
import 'utils/admob_helper.dart';

class NoteList extends StatefulWidget {
  int lang;
  Color color;
  bool adOpen;

  NoteList(this.lang, this.color, this.adOpen);

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Category> allCategories;

  InterstitialAd myInterstitialAd, myInterstitialAdExit;

  Map<String, String> texts;

  Map<String, String> english = {
    "Home": "Home",
    "search": "Search",
    "PopupMenuItem": "Categories",
    "PopupMenuItem1": "All Notes",
    "FloatingActionButton_tooltip": "+New",
    "addCategoryDialog_SimpleDialog_title": "Add Category",
    "Edit_Category": "Edit Category",
    "addCategoryDialog_SimpleDialog_TextFormField_labelText": "Category Name",
    "addCategoryDialog_SimpleDialog_TextFormField_validator":
        "Please enter least 3 character",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton": "Cancel ❌",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1_SnackBar":
        "category successfully added 👌",
    "editCategory_SnackBar": "category successfully edited 👌",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1": "Save 💾",
    'Select_a_color': 'Select a color',
    "Delete": "Delete🗑",
    "_sureForDelCategory_baslik": "Are you sure?",
    "_sureForDelCategory_icerik": "Are you sure for delete the category?\n" +
        "This action will delete all notes in this category.",
    "_sureForDelCategory_anaButonYazisi": "Yes",
    "_sureForDelCategory_iptalButonYazisi": "No",
    "_areYouSureforDelete_baslik": "Are you Sure?",
    "_areYouSureforDelete_icerik": "Are you sure for exit to Mr. Note?",
    "_areYouSureforDelete_anaButonYazisi": "EXIT",
    "_areYouSureforDelete_iptalButonYazisi": "CANCEL",
  };

  Map<String, String> turkish = {
    "Home": "Ana Sayfa",
    "search": "Ara",
    "PopupMenuItem": "Kategoriler",
    "PopupMenuItem1": "Tüm Notlar",
    "FloatingActionButton_tooltip": "+Yeni",
    "addCategoryDialog_SimpleDialog_title": "Kategori Ekle",
    "Edit_Category": "Kategori Düzenle",
    "addCategoryDialog_SimpleDialog_TextFormField_labelText": "Kategori Adı",
    "addCategoryDialog_SimpleDialog_TextFormField_validator":
        "Lütfen en az 3 karakter giriniz",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton": "İptal ❌",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1_SnackBar":
        "Kategori başarıyla eklendi 👌",
    "editCategory_SnackBar": "Kategori başarıyla düzenlendi 👌",
    "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1": "Kaydet 💾",
    'Select_a_color': 'Bir Renk Seç',
    "Delete": "Kaldır",
    "_sureForDelCategory_baslik": "Emin misiniz?",
    "_sureForDelCategory_icerik":
        "Kategoriyi silmek istediğinizden emin misiniz?\n" +
            "Bu işlem, bu kategorideki tüm notları silecek.",
    "_sureForDelCategory_anaButonYazisi": "Evet",
    "_sureForDelCategory_iptalButonYazisi": "Hayır",
    "_areYouSureforDelete_baslik": "Emin misiniz?",
    "_areYouSureforDelete_icerik":
        "Mr. Not dan çıkmak istediğinizden emin misiniz?",
    "_areYouSureforDelete_anaButonYazisi": "ÇIK",
    "_areYouSureforDelete_iptalButonYazisi": "İPTAL",
  };

  bool adOpen;

  String newCategoryTitle;

  Color currentColor = Colors.red, editColor;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.adOpen) {
      adInitialize();
    }
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
    var size = MediaQuery.of(context).size;
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
                buildCategories(size),
                Notes(
                  adOpen,
                  lang: widget.lang,
                  color: widget.color,
                )
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
          RaisedButton(
            child: Text(
              texts["search"],
              style: headerStyle3,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      SearchPage(widget.lang, widget.color, widget.adOpen)));
            },
          ),
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
                  updateCategoryList();
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

  Future<String> _goToPage(Object page) async {
    final result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => page));
    return result;
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
              changeColorWidget(context),
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
                            .addCategory(
                                Category(newCategoryTitle, currentColor.value))
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

  Widget changeColorWidget(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter blockPickerState) {
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text(
                texts['Select_a_color'],
                style: TextStyle(
                    color: Theme
                        .of(context)
                        .primaryColor, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 80),
              child: GestureDetector(
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: currentColor),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(texts['Select_a_color']),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: currentColor,
                            onColorChanged: (Color color) {
                              Navigator.pop(context);
                              blockPickerState(() {
                                currentColor = color;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }

  void updateCategoryList() {
    databaseHelper.getCategoryList().then((categoryList) {
      categoryList.insert(
          0, Category.withID(0, texts["PopupMenuItem1"], widget.color.value));
      setState(() {
        allCategories = categoryList;
      });
    });
  }

  Widget buildCategories(Size size) {
    return Container(
      height: 130,
      width: size.width,
      child: ListView.builder(
          itemCount: allCategories.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0, left: 10),
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                      borderRadius: borderRadis1, color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(allCategories[index].categoryColor)),
                        ),
                        Text(
                          allCategories[index].categoryTitle,
                          style: headerStyle4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        Category_Page(allCategories[index],
                            widget.lang, widget.color, widget.adOpen)));
              },
              onLongPress: () {
                if (index != 0) {
                  editCategoryDialog(context, allCategories[index]);
                }
              },
            );
          }),
    );
  }

  void editCategoryDialog(BuildContext context, Category category) {
    var formKey = GlobalKey<FormState>();

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              texts["Edit_Category"],
              style: TextStyle(color: Theme
                  .of(context)
                  .primaryColor),
            ),
            children: <Widget>[
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: category.categoryTitle,
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
                    onChanged: (value) {
                      category.categoryTitle = value;
                    },
                  ),
                ),
              ),
              editColorWidget(context, category),
              ButtonBar(
                alignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.red,
                    child: Text(
                      texts["Delete"],
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      _sureForDelCategory(context, category.categoryID);
                    },
                  ),
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
                            .updateCategory(Category.withID(category.categoryID,
                            newCategoryTitle, category.categoryColor))
                            .then((value) {
                          if (value > 0) {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text(texts["editCategory_SnackBar"]),
                              duration: Duration(seconds: 2),
                            ));
                            newCategoryTitle = null;
                            Navigator.pop(context);
                            setState(() {
                              updateCategoryList();
                            });
                          }
                        });
                      }
                    },
                    color: Colors.green,
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

  Widget editColorWidget(BuildContext context, Category category) {
    Color categoryColor = Color(category.categoryColor);
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter blockPickerState) {
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text(
                texts['Select_a_color'],
                style: TextStyle(
                    color: Theme
                        .of(context)
                        .primaryColor, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 80),
              child: GestureDetector(
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: categoryColor),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(texts['Select_a_color']),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: categoryColor,
                            onColorChanged: (Color color) {
                              Navigator.pop(context);
                              blockPickerState(() {
                                category.categoryColor = color.value;
                                categoryColor = color;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }

  void _sureForDelCategory(BuildContext context, int categoryID) async {
    final result = await PlatformDuyarliAlertDialog(
      baslik: texts["_sureForDelCategory_baslik"],
      icerik: texts["_sureForDelCategory_icerik"],
      anaButonYazisi: texts["_sureForDelCategory_anaButonYazisi"],
      iptalButonYazisi: texts["_sureForDelCategory_iptalButonYazisi"],
    ).goster(context);

    if (result) {
      _delCategory(context, categoryID);
    }
  }

  void _delCategory(BuildContext context, int categoryID) {
    databaseHelper.deleteCategory(categoryID).then((deletedCategory) {
      if (deletedCategory != 0) {
        setState(() {
          updateCategoryList();
        });
        Navigator.pop(context);
      }
    });
  }

  Future<bool> _areYouSureforExit() async {
    final sonuc = await PlatformDuyarliAlertDialog(
      baslik: texts["_areYouSureforDelete_baslik"],
      icerik: texts["_areYouSureforDelete_icerik"],
      anaButonYazisi: texts["_areYouSureforDelete_anaButonYazisi"],
      iptalButonYazisi: texts["_areYouSureforDelete_iptalButonYazisi"],
    ).goster(context);

    if (sonuc) {
      if (widget.adOpen) {
        return showAd();
      }
      return Future.value(true);
    }
    return Future.value(false);
  }

  Future<bool> showAd() async {
    myInterstitialAdExit..show();
    return Future.value(true);
  }
}

class Notes extends StatefulWidget {
  int lang;
  Color color;
  bool adOpen;

  Notes(this.adOpen, {this.lang, this.color});

  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  List<Note> allNotes;
  DatabaseHelper databaseHelper;

  Map<String, dynamic> texts;

  Map<String, dynamic> english = {
    "Padding": "Welcome again 🥳\n" + "You didn't edit any notes today 😉",
    "Recent_Notes": "Recent Mr. Notes",
    "FloatingActionButton_tooltip": "+New",
    "Sort_Title": "Sort Mr. Note",
    "SortList": ["Category", "Title", "Content", "Time", "Priority"],
    "OrderList": ["Ascending", "Descending"],
    "Cancel": "Cancel",
    "Sort": "Sort",
  };

  Map<String, dynamic> turkish = {
    "Padding": "Tekrar hoşgeldin 🥳\n" + "Bugün hiçbir not düzenlemedin 😉",
    "Recent_Notes": "Son Mr. Notlar",
    "FloatingActionButton_tooltip": "+Yeni",
    "Sort_Title": "Mr. Notu Sırala",
    "SortList": ["Kategori", "Başlık", "İçerik", "Zaman", "Öncelik"],
    "OrderList": ["Artan", "Azalan"],
    "Cancel": "İptal",
    "Sort": "Sırala",
  };

  ContainerTransitionType _transitionType = ContainerTransitionType.fade;

  int sortBy, orderBy;
  bool isSorted = false;

  @override
  void initState() {
    super.initState();
    allNotes = List<Note>();
    databaseHelper = DatabaseHelper();
    readSort();
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
    var _sortList = texts["SortList"];
    var _orderList = texts["OrderList"];
    fillAllNotes();
    Size size = MediaQuery
        .of(context)
        .size;
    return Container(
      child: Column(
        children: <Widget>[
          buildRecentOnesAndFilterHeader(_sortList, _orderList),
          SizedBox(
            height: 10,
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
            width: size.width * 0.85,
            child: BuildNoteList(
              widget.lang,
              widget.color,
              widget.adOpen,
              isSorted: isSorted,
            ),
          )
        ],
      ),
    );
  }

  Future<void> fillAllNotes() async {
    List<Note> allNotes1;
    String suan = DateTime.now().toString().substring(0, 10);
    allNotes1 = await databaseHelper.getTodayNoteList(suan);
    setState(() {
      allNotes = allNotes1;
    });
  }

  Widget buildRecentOnesAndFilterHeader(List<String> sortList,
      List<String> orderList) {
    return Container(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 30, top: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              texts["Recent_Notes"],
              style: headerStyle2,
            ),
            Row(
              children: [
                OpenContainer(
                  onClosed: (result) {
                    if (result != null) {
                      setState(() {});
                    }
                  },
                  transitionType: _transitionType,
                  openBuilder: (BuildContext context, VoidCallback _) {
                    return NoteDetail(widget.lang, widget.color);
                  },
                  closedElevation: 6.0,
                  closedColor: widget.color,
                  closedBuilder:
                      (BuildContext context, VoidCallback openContainer) {
                    return Text(
                      texts["FloatingActionButton_tooltip"],
                      style: headerStyle2,
                    );
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  child: Icon(Icons.sort),
                  onTap: () {
                    sortNotesDialog(context, sortList, orderList);
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  sortNotesDialog(BuildContext context, List<String> sortList,
      List<String> orderList) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              texts["Sort_Title"],
              style: TextStyle(color: Theme
                  .of(context)
                  .primaryColor),
            ),
            contentPadding: const EdgeInsets.only(left: 25),
            children: <Widget>[
              dropDown(sortList),
              dropDownOrder(orderList),
              ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        isSorted = false;
                      });
                      Navigator.pop(context);
                    },
                    color: Colors.orangeAccent,
                    child: Text(
                      texts["Cancel"],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      var suan = DateTime.now();
                      String sort =
                          sortBy.toString() + "/" + orderBy.toString();
                      databaseHelper.updateSettingsNote(
                          Note(0, "Sort", sort, suan.toString(), 2));
                      setState(() {
                        isSorted = true;
                      });
                      Navigator.pop(context);
                    },
                    color: Colors.redAccent,
                    child: Text(
                      texts["Sort"],
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              )
            ],
          );
        });
  }

  Future<void> readSort() async {
    try {
      List<Note> sortNoteList =
      await databaseHelper.getSettingsNoteTitleList("Sort");
      String sortContent = sortNoteList[0].noteContent;
      List<String> sortList = sortContent.split("/");
      setState(() {
        sortBy = int.parse(sortList[0]);
        orderBy = int.parse(sortList[1]);
      });
    } catch (e) {
      setState(() {
        sortBy = 3;
        orderBy = 1;
      });
    }
  }

  Widget dropDown(List<String> sortList) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter dropDownState) {
        return DropdownButton(
          value: sortBy,
          icon: Icon(Icons.keyboard_arrow_down),
          iconSize: 20,
          style: TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.transparent,
          ),
          onChanged: (selectedSortBy) {
            dropDownState(() {
              sortBy = selectedSortBy;
            });
          },
          items: sortList.map((e) {
            return DropdownMenuItem<int>(
              child: Text(
                e,
                style: headerStyle3_1,
              ),
              value: sortList.indexOf(e),
            );
          }).toList(),
        );
      },
    );
  }

  Widget dropDownOrder(List<String> orderList) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter dropDownOrderState) {
        return DropdownButton<int>(
          value: orderBy,
          icon: Icon(Icons.keyboard_arrow_down),
          iconSize: 20,
          style: TextStyle(color: Colors.deepPurple),
          underline: Container(
            color: Colors.transparent,
          ),
          onChanged: (selectedOrderBy) {
            dropDownOrderState(() {
              orderBy = selectedOrderBy;
            });
          },
          items: createOrderByItem(orderList),
        );
      },
    );
  }

  List<DropdownMenuItem<int>> createOrderByItem(List<String> orderList) {
    return orderList
        .map((order) =>
        DropdownMenuItem<int>(
          value: orderList.indexOf(order),
          child: Text(
            order,
            style: headerStyle3,
          ),
        ))
        .toList();
  }
}
