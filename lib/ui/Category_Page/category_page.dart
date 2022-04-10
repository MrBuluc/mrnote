import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mrnote/common_widget/build_note_list.dart';
import 'package:mrnote/common_widget/new_button.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/models/settings.dart';
import 'package:mrnote/services/database_helper.dart';

import '../../const.dart';

class CategoryPage extends StatefulWidget {
  final Category category;

  CategoryPage({@required this.category});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  AdmobInterstitial myInterstitialAd;

  Map<String, String> texts;

  Map<String, String> english = {
    "notes": "Mr. Notes",
    "Padding": "It looks a bit cold around here 🥶\n" + "Let's warm it up 🥳",
  };

  Map<String, String> turkish = {
    "notes": "Mr. Notlar",
    "Padding": "Buralar soğuk gözüküyor 🥶\n" + "Hadi biraz ısıtalım 🥳",
  };

  Category category;

  Settings settings = Settings();

  int length = 0;

  @override
  void initState() {
    super.initState();
    if (settings.adOpen) {
      adInitialize();
    }
    switch (settings.lang) {
      case 0:
        texts = english;
        break;
      case 1:
        texts = turkish;
        break;
    }
    category = widget.category;
  }

  @override
  void dispose() {
    if (settings.adOpen) {
      disposeAd();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
              FutureBuilder(
                future: getLengthNotes(),
                builder: (context, _) {
                  if (length == 0)
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          texts["Padding"],
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    );
                  else
                    return Container(
                        height: 150.0 * length,
                        child: BuildNoteList(
                          categoryID: category.categoryID,
                        ));
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void adInitialize() async {
    myInterstitialAd = AdmobInterstitial(
        adUnitId: Settings.test
            ? AdmobInterstitial.testAdUnitId
            : Settings.gecis1Canli,
        listener: (AdmobAdEvent event, Map<String, dynamic> args) {
          switch (event) {
            case AdmobAdEvent.loaded:
              myInterstitialAd.show();
              break;
            default:
              print("args: " + args.toString());
              break;
          }
        });

    myInterstitialAd.load();
  }

  void disposeAd() {
    myInterstitialAd.dispose();
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
              padding: const EdgeInsets.only(bottom: 8.0, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$length ${texts["notes"]}",
                    style: headerStyle7,
                  ),
                  category.categoryID != 0
                      ? NewButton(
                          lang: settings.lang,
                          closedColor: Colors.white,
                          categoryID: category.categoryID,
                          categoryColor: category.categoryColor,
                        )
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getLengthNotes() async {
    int lengthLocal, categoryID = category.categoryID;
    if (categoryID == 0) {
      lengthLocal = await databaseHelper.lenghtAllNotes();
    } else {
      lengthLocal = await databaseHelper.lenghtCategoryNotes(categoryID);
    }
    setState(() {
      length = lengthLocal;
    });
  }
}
