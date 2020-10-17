import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:mrnote/common_widget/platform_duyarli_alert_dialog.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/utils/database_helper.dart';

import 'utils/admob_helper.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<Category> allCategories;
  DatabaseHelper databaseHelper;

  InterstitialAd myInterstitialAd;

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    AdmobHelper.admobInitialize();
    myInterstitialAd = AdmobHelper.buildInterstitialAd();
    myInterstitialAd
      ..load()
      ..show();
    AdmobHelper.myBannerAd = AdmobHelper.buildBannerAd();
    AdmobHelper.myBannerAd
      ..load()
      ..show(anchorOffset: 10);
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
          title: Text("Categories"),
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
      baslik: "Are you sure?",
      icerik: "Are you sure to delete the category?\n" +
          "This action will delete all notes in this category.",
      anaButonYazisi: "Yes",
      iptalButonYazisi: "No",
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
              "Update Category",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: <Widget>[
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: updateCategory.categoryTitle,
                    decoration: InputDecoration(
                      labelText: "Category Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value.length < 3) {
                        return "Please enter least 3 character";
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
                      "Cancel",
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
                              content: Text("category successfully updated"),
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
                      "Update",
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
