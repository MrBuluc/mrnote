import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mrnote/common_widget/merkez_widget.dart';
import 'package:mrnote/common_widget/new_button.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/models/note.dart';
import 'package:mrnote/models/settings.dart';
import 'package:mrnote/services/database_helper.dart';

import '../../common_widget/Platform_Duyarli_Alert_Dialog/platform_duyarli_alert_dialog.dart';
import '../../common_widget/build_note_list.dart';
import '../../const.dart';
import '../Category_Page/category_page.dart';
import '../Search_Page/search_page.dart';
import '../Settings/SettingsPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Category> allCategories = [];

  late Map<String, String> texts;
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
    "_sureForDelCategory_2Categories_icerik":
        "Every Mr. Note needs a category. So make sure you have created at least 1 category before "
            "creating a Mr. Note! ",
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
    "_sureForDelCategory_2Categories_icerik":
        "Her Mr. Notun bir kategoriye ihtiyacı vardır. Bundan "
            "dolayı Mr. Note oluşturmadan önce en az 1 kategori oluşturduğunuzdan emin olun! ",
    "_areYouSureforDelete_baslik": "Emin misiniz?",
    "_areYouSureforDelete_icerik":
        "Mr. Not dan çıkmak istediğinizden emin misiniz?",
    "_areYouSureforDelete_anaButonYazisi": "ÇIK",
    "_areYouSureforDelete_iptalButonYazisi": "İPTAL",
  };

  String? newCategoryTitle;

  Color currentColor = Colors.red;

  Settings settings = Settings();

  late Size size;

  @override
  Widget build(BuildContext context) {
    switch (settings.lang) {
      case 0:
        texts = english;
        break;
      case 1:
        texts = turkish;
        break;
    }
    if (allCategories.isEmpty) {
      updateCategoryList();
    }
    size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: settings.currentColor,
          body: ListView(
            children: <Widget>[
              SizedBox(
                height: 25,
              ),
              header(),
              categoriesAndNew(),
              buildCategories(),
              Notes()
            ],
          )),
    );
  }

  Future updateCategoryList() async {
    allCategories = await databaseHelper.getCategoryList();
    allCategories.insert(
        0,
        Category.withID(
            0, texts["PopupMenuItem1"]!, settings.currentColor!.value));
    setState(() {});
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(texts["Home"]!, style: headerStyle),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: settings.currentColor),
            child: Text(
              texts["search"]!,
              style: headerStyle3,
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => SearchPage()));
            },
          ),
          GestureDetector(
            child: Icon(
              Icons.settings,
              color: Colors.grey.shade800,
              size: 30,
            ),
            onTap: () async {
              String? result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingsPage()));
              if (result != null) {
                updateCategoryList();
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
              texts["PopupMenuItem"]!,
              style: headerStyle2,
            ),
            GestureDetector(
              child: Text(
                texts["FloatingActionButton_tooltip"]!,
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
              texts["addCategoryDialog_SimpleDialog_title"]!,
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
                      if (value != null) {
                        if (value.length < 3) {
                          return texts[
                              "addCategoryDialog_SimpleDialog_TextFormField_validator"];
                        } else
                          return null;
                      }
                      return texts[
                          "addCategoryDialog_SimpleDialog_TextFormField_validator"];
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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent),
                    child: Text(
                      texts[
                          "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton"]!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        databaseHelper
                            .addCategory(
                                Category(newCategoryTitle!, currentColor.value))
                            .then((value) {
                          if (value > 0) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(texts[
                                  "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1_SnackBar"]!),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: Text(
                      texts[
                          "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1"]!,
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
                texts['Select_a_color']!,
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 20),
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
                        title: Text(texts['Select_a_color']!),
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

  Widget buildCategories() {
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
                      borderRadius: borderRadis1,
                      color: settings.switchBackgroundColor()),
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
                          style: switchCategoriesTitleStyle(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CategoryPage(
                          category: allCategories[index],
                        )));
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

  TextStyle switchCategoriesTitleStyle() {
    switch (settings.currentColor.hashCode) {
      //black color
      case 4278190080:
        return headerStyle4.copyWith(color: Colors.white);
      default:
        return headerStyle4;
    }
  }

  void editCategoryDialog(BuildContext context, Category category) {
    var formKey = GlobalKey<FormState>();

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              texts["Edit_Category"]!,
              style: TextStyle(color: Theme.of(context).primaryColor),
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
                      if (value != null) {
                        if (value.length < 3) {
                          return texts[
                              "addCategoryDialog_SimpleDialog_TextFormField_validator"];
                        } else
                          return null;
                      }
                      return texts[
                          "addCategoryDialog_SimpleDialog_TextFormField_validator"];
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
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text(
                      texts["Delete"]!,
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      _sureForDelCategory(context, category.categoryID!);
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent),
                    child: Text(
                      texts[
                          "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton"]!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        databaseHelper
                            .updateCategory(Category.withID(category.categoryID,
                                newCategoryTitle!, category.categoryColor))
                            .then((value) {
                          if (value > 0) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(texts["editCategory_SnackBar"]!),
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
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text(
                      texts[
                          "addCategoryDialog_SimpleDialog_ButtonBar_RaisedButton1"]!,
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
                texts['Select_a_color']!,
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 20),
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
                        title: Text(texts['Select_a_color']!),
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
      baslik: texts["_sureForDelCategory_baslik"]!,
      icerik: allCategories.length == 2
          ? texts["_sureForDelCategory_2Categories_icerik"]! +
              texts["_sureForDelCategory_icerik"]!
          : texts["_sureForDelCategory_icerik"]!,
      anaButonYazisi: texts["_sureForDelCategory_anaButonYazisi"]!,
      iptalButonYazisi: texts["_sureForDelCategory_iptalButonYazisi"],
    ).goster(context);

    if (result) {
      _delCategory(context, categoryID);
    }
  }

  Future _delCategory(BuildContext context, int categoryID) async {
    int deletedCategory = await databaseHelper.deleteCategory(categoryID);
    if (deletedCategory != 0) {
      updateCategoryList();
      Navigator.pop(context);
    }
  }
}

class Notes extends StatefulWidget {
  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late DatabaseHelper databaseHelper;

  late Map<String, dynamic> texts;
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

  int? sortBy, orderBy, length = 0;

  bool isSorted = false, read = false;

  Settings settings = Settings();

  late List<String> sortList, orderList;

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    readSort();
  }

  Future<void> readSort() async {
    try {
      List<Note> sortNoteList =
          await databaseHelper.getSettingsNoteTitleList("Sort");
      String sortContent = sortNoteList[0].noteContent!;
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

  @override
  Widget build(BuildContext context) {
    switch (settings.lang) {
      case 0:
        texts = english;
        break;
      case 1:
        texts = turkish;
        break;
    }
    sortList = texts["SortList"];
    orderList = texts["OrderList"];
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        children: <Widget>[
          buildRecentOnesAndFilterHeader(),
          SizedBox(
            height: 10,
          ),
          FutureBuilder(
            future: getTodayNotesLenght(),
            builder: (context, _) {
              if (!read)
                return MerkezWidget(children: [CircularProgressIndicator()]);
              else if (length == 0)
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      texts["Padding"],
                      style:
                          TextStyle(fontSize: 20, color: Colors.grey.shade800),
                    ),
                  ),
                );
              return Container(
                height: 150.0 * length!,
                width: size.width * 0.85,
                child: BuildNoteList(
                  isSorted: isSorted,
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget buildRecentOnesAndFilterHeader() {
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
                NewButton(
                  lang: settings.lang!,
                  closedColor: settings.currentColor!,
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  child: Icon(Icons.sort),
                  onTap: () {
                    sortNotesDialog(context);
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  sortNotesDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              texts["Sort_Title"],
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            contentPadding: const EdgeInsets.only(left: 25),
            children: <Widget>[
              dropDown(),
              dropDownOrder(),
              ButtonBar(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSorted = false;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent),
                    child: Text(
                      texts["Cancel"],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
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

  Widget dropDown() {
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

  Widget dropDownOrder() {
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
          items: createOrderByItem(),
        );
      },
    );
  }

  List<DropdownMenuItem<int>> createOrderByItem() {
    return orderList
        .map((order) => DropdownMenuItem<int>(
              value: orderList.indexOf(order),
              child: Text(
                order,
                style: headerStyle3,
              ),
            ))
        .toList();
  }

  Future<void> getTodayNotesLenght() async {
    String suan = DateTime.now().toString().substring(0, 10);
    int lenghtLocal = await databaseHelper.isThereAnyTodayNotes(suan);
    setState(() {
      length = lenghtLocal;
      read = true;
    });
  }
}
