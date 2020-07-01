import 'package:flutter/material.dart';
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
          primarySwatch: Colors.purple, primaryColor: Color(0xFFff0000)),
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
          return ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
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
                                  "Category: ",
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
                                  "Creation Date: ",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  databaseHelper.dateFormat(
                                      DateTime.parse(allNotes[index].noteTime)),
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
                                labelText: "Content",
                                border: OutlineInputBorder(),
                              ),
                              initialValue: allNotes[index].noteContent,
                              readOnly: true,
                            )
                            //Text(allNotes[index].noteContent, style: TextStyle(fontSize: 20),),
                          )
                        ],
                      ),
                    )
                  ],
                );
              });
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
