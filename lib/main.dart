import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mrnote/category_operations.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/models/notes.dart';
import 'package:mrnote/note_detail.dart';
import 'package:mrnote/utils/database_helper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
          primarySwatch: Colors.purple,
          primaryColor: Color(0xFFff0000),
          accentColor: Colors.orange),
      home: NoteList(),
    );
  }
}

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
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
                  title: Text("Categories"),
                  onTap: () async {
                    Navigator.pop(context);
                    var result = await _goToCategoriesPage();
                    if (result != null) {
                      setState(() {});
                    }
                  },
                )),

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
            tooltip: "Add Category",
            child: Icon(Icons.import_contacts),
            mini: true,
            heroTag: "Add Category",
          ),
          FloatingActionButton(
            onPressed: () async {
              var result = await _goToDetailPage(context);
              if (result != null) {
                setState(() {});
              }
            },
            tooltip: "Add Note",
            child: Icon(Icons.add),
            heroTag: "Add Note",
          ),
        ],
      ),
      body: Notes(),
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
              "Add Category",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: <Widget>[
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
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
                      "Cancel",
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
                              content: Text("category successfully added"),
                              duration: Duration(seconds: 2),
                            ));
                            Navigator.pop(context);
                          }
                        });
                      }
                    },
                    color: Colors.redAccent,
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  Future<String> _goToDetailPage(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NoteDetail(
                  title: "New Note",
                )));
    return result;
  }

  Future<String> _goToCategoriesPage() async {
    final result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Categories()));
    return result;
  }
}

class Notes extends StatefulWidget {
  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  List<Note> allNotes;
  DatabaseHelper databaseHelper;
  Color red = Color(0xFFff0000);

  @override
  void initState() {
    super.initState();
    allNotes = List<Note>();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseHelper.getNoteList(),
      builder: (context, AsyncSnapshot<List<Note>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          allNotes = snapshot.data;
          sleep(Duration(milliseconds: 500));
          return allNotes.length == 0
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      "Before create new note, you have to create new category",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: allNotes.length,
                  itemBuilder: (context, index) {
                    return ExpansionTile(
                      leading:
                          _setPriorityIcon(allNotes[index].notePriority),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      "Category: ",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      allNotes[index].categoryTitle,
                                      style: TextStyle(
                                          color: red, fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      "Creation Date: ",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      databaseHelper.dateFormat(
                                          DateTime.parse(
                                              allNotes[index].noteTime)),
                                      style: TextStyle(
                                          color: red, fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: TextFormField(
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      labelText: "Content",
                                      border: OutlineInputBorder(),
                                    ),
                                    initialValue:
                                        allNotes[index].noteContent,
                                    readOnly: true,
                                  )
                                  //Text(allNotes[index].noteContent, style: TextStyle(fontSize: 20),),
                                  ),
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
                                      "Update",
                                      style: TextStyle(
                                          color: allNotes[index]
                                                      .notePriority ==
                                                  2
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 20),
                                    ),
                                    color: _setBackgroundColor(
                                        allNotes[index].notePriority),
                                  ),
                                  RaisedButton(
                                    onPressed: () =>
                                        _delNote(allNotes[index].noteID),
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(
                                          color: _setBackgroundColor(
                                              allNotes[index]
                                                  .notePriority),
                                          fontSize: 20),
                                    ),
                                    color:
                                        allNotes[index].notePriority == 2
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
        } else {
          return Center(
            child: Text(
              "Loading...",
              style: TextStyle(fontSize: 28),
            ),
          );
        }
      },
    );
  }

  Future<String> _goToDetailPage(BuildContext context, Note note) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NoteDetail(
                  title: "Update Note",
                  updateNote: note,
                )));
    return result;
  }

  _setPriorityIcon(int notePriority) {
    switch (notePriority) {
      case 0:
        return CircleAvatar(
          child: Text(
            "Low",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.green,
        );
        break;
      case 1:
        return CircleAvatar(
          child: Text(
            "Medium",
            style: TextStyle(color: Colors.black, fontSize: 10),
          ),
          backgroundColor: Colors.yellow,
        );
        break;
      case 2:
        return CircleAvatar(
            child: Text(
              "High",
              style: TextStyle(color: Colors.white),
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
          content: Text("Note Deleted"),
        ));

        setState(() {});
      }
    });
  }
}
