import 'package:flutter/material.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  String title;
  NoteDetail({this.title});
  @override
  _NoteDetailState createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  var formkey = GlobalKey<FormState>();
  List<Category> allCategories;
  DatabaseHelper databaseHelper;
  int categoryID = 1;

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
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Form(
          key: formkey,
          child: Column(
            children: <Widget>[
              Center(
                child: Container(
                  child: DropdownButtonHideUnderline(
                    child: allCategories.length <= 0
                        ? CircularProgressIndicator()
                        : DropdownButton<int>(
                            items: createCategoryItem(),
                            value: categoryID,
                            onChanged: (selectedCategoryID) {
                              setState(() {
                                categoryID = selectedCategoryID;
                              });
                            },
                          ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 25),
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  List<DropdownMenuItem<int>> createCategoryItem() {
    return allCategories
        .map((category) => DropdownMenuItem<int>(
              value: category.categoryID,
              child: Text(category.categoryTitle, style: TextStyle(fontSize: 20),),
            ))
        .toList();
  }
}
