import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:mrnote/common_widget/platform_duyarli_alert_dialog.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/utils/database_helper.dart';

import 'utils/admob_helper.dart';

class Categories extends StatefulWidget {
  int lang;

  Categories({this.lang});

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<Category> allCategories;
  DatabaseHelper databaseHelper;

  InterstitialAd myInterstitialAd;

  Map<String, String> texts;

  Map<String, String> english = {
    "AppBar": "Categories",
    "_sureForDelCategory_baslik": "Are you sure?",
    "_sureForDelCategory_icerik": "Are you sure for delete the category?\n" +
        "This action will delete all notes in this category.",
    "_sureForDelCategory_anaButonYazisi": "Yes",
    "_sureForDelCategory_iptalButonYazisi": "No",
    "updateCategoryDialog_title": "Update Category",
    "updateCategoryDialog_Padding_labelText": "Category Name",
    "updateCategoryDialog_Padding_validator": "Please enter least 3 character",
    "updateCategoryDialog_RaisedButton": "Cancel",
    "updateCategoryDialog_RaisedButton1_SnackBar":
        "category successfully updated",
    "updateCategoryDialog_RaisedButton1": "Update",
  };

  Map<String, String> turkish = {
    "AppBar": "Kategoriler",
    "_sureForDelCategory_baslik": "Emin misiniz?",
    "_sureForDelCategory_icerik":
        "Kategoriyi silmek istediğinizden emin misiniz?\n" +
            "Bu işlem, bu kategorideki tüm notları silecek.",
    "_sureForDelCategory_anaButonYazisi": "Evet",
    "_sureForDelCategory_iptalButonYazisi": "Hayır",
    "updateCategoryDialog_title": "Kategori Güncelle",
    "updateCategoryDialog_Padding_labelText": "Kategori Adı",
    "updateCategoryDialog_Padding_validator": "Lütfen en az 3 karakter giriniz",
    "updateCategoryDialog_RaisedButton": "İptal",
    "updateCategoryDialog_RaisedButton1_SnackBar":
        "kategori başarıyla güncellendi 👌",
    "updateCategoryDialog_RaisedButton1": "Güncelle",
  };

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    // AdmobHelper.admobInitialize();
    // myInterstitialAd = AdmobHelper.buildInterstitialAd();
    // myInterstitialAd
    //   ..load()
    //   ..show();
    // AdmobHelper.myBannerAd = AdmobHelper.buildBannerAd();
    // AdmobHelper.myBannerAd
    //   ..load()
    //   ..show(anchorOffset: 10);
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
    myInterstitialAd.dispose();
    AdmobHelper.myBannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (allCategories == null) {
      allCategories = List<Category>();
      updateCategoryList();
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(texts["AppBar"]),
        ),
        body: ListView.builder(
            itemCount: allCategories.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () => _updateCategory(allCategories[index], context),
                title: Text(
                  allCategories[index].categoryTitle,
                  style: TextStyle(fontSize: 20),
                ),
                trailing: GestureDetector(
                  child: Icon(
                    Icons.delete,
                    color: Theme.of(context).accentColor,
                  ),
                  onTap: () => _sureForDelCategory(
                      context, allCategories[index].categoryID),
                ),
                leading: Icon(
                  Icons.import_contacts,
                  color: Colors.blue,
                ),
              );
            }));
  }

  void updateCategoryList() {
    databaseHelper.getCategoryList().then((categoryList) {
      setState(() {
        allCategories = categoryList;
      });
    });
  }

  _sureForDelCategory(BuildContext context, int categoryID) async {
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
        Navigator.pop(context, "deleted");
      }
    });
  }

  _updateCategory(Category updateCategory, BuildContext context) {
    updateCategoryDialog(context, updateCategory);
  }

  void updateCategoryDialog(BuildContext myContext, Category updateCategory) {
    var formKey = GlobalKey<FormState>();
    String updateCategoryTitle;

    showDialog(
        barrierDismissible: false,
        context: myContext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              texts["updateCategoryDialog_title"],
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
                    initialValue: updateCategory.categoryTitle,
                    decoration: InputDecoration(
                      labelText:
                      texts["updateCategoryDialog_Padding_labelText"],
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value.length < 3) {
                        return texts["updateCategoryDialog_Padding_validator"];
                      } else
                        return null;
                    },
                    onSaved: (value) {
                      updateCategoryTitle = value;
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
                      texts["updateCategoryDialog_RaisedButton"],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        databaseHelper
                            .updateCategory(Category.withID(
                                updateCategory.categoryID, updateCategoryTitle))
                            .then((catID) {
                          if (catID != 0) {
                            Scaffold.of(myContext).showSnackBar(SnackBar(
                              content: Text(texts[
                              "updateCategoryDialog_RaisedButton1_SnackBar"]),
                              duration: Duration(seconds: 2),
                            ));
                            updateCategoryList();
                            Navigator.of(context).pop();
                            Navigator.of(context).pop("updated");
                          }
                        });
                      }
                    },
                    color: Colors.redAccent,
                    child: Text(
                      texts["updateCategoryDialog_RaisedButton1"],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }
}
