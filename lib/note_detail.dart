import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/models/notes.dart';
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
  static var _priority = ["Low", "Medium", "High"];
  int selectedPriority = 0;
  String noteTitle, noteContent;

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
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: allCategories.length <= 0
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Container(
        child: Form(
          key: formkey,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Category :",
                      style:
                      TextStyle(fontSize: 20, color: Colors.purple),
                    ),
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
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
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter Note Title",
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (text) {
                    noteTitle = text;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Enter Note Content",
                    labelText: "Content",
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (text) {
                    noteContent = text;
                  },
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Priority: ",
                      style: TextStyle(
                          fontSize: 20, color: Color(0xFFff0000)),
                    ),
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
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
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                //mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      padding: const EdgeInsets.all(20),
                    ),
                    color: Colors.orangeAccent,

                  ),
                  RaisedButton(
                    onPressed: () {
                      formkey.currentState.save();
                      var suan = DateTime.now();
                      databaseHelper.addNote(Note(
                          categoryID, noteTitle, noteContent, suan.toString(), selectedPriority))
                          .then((savedNoteID) {
                        if (savedNoteID != 0) {
                          Navigator.pop(context, "update");
                        }
                      });
                    },
                    child: Padding(
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      padding: const EdgeInsets.all(20),
                    ),
                    color: Colors.redAccent,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<int>> createCategoryItem() {
    return allCategories
        .map((category) =>
        DropdownMenuItem<int>(
          value: category.categoryID,
          child: Text(
            category.categoryTitle,
            style: TextStyle(fontSize: 20),
          ),
        ))
        .toList();
  }
}

/*
* Form(
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
        )*/
