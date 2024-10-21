import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/models/note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  static int counter = 0;

  String selectNoteSql =
      "Select * From note Inner Join category on category.categoryID = note.categoryID";

  factory DatabaseHelper() {
    if (_database == null) {
      _databaseHelper = DatabaseHelper.internal();
      return _databaseHelper!;
    } else {
      return _databaseHelper!;
    }
  }

  DatabaseHelper.internal();

  Future<Database> _getDatabase() async {
    if (_database == null) {
      _database = await _initializeDatabase();
      return _database!;
    } else {
      return _database!;
    }
  }

  Future<Database> _initializeDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "notes.db");

    // Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "notes.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
    // open the database
    return await openDatabase(path, readOnly: false);
  }

  Future<int> lenghtAllNotes() async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> sonuc =
        await db.rawQuery("SELECT COUNT() FROM note Where categoryID != 0;");
    return sonuc[0]["COUNT()"];
  }

  Future<int> isThereAnyTodayNotes(String suan) async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> sonuc = await db.rawQuery(
        "SELECT COUNT() FROM note WHERE noteTime LIKE '$suan%' And categoryID != 0;");
    return sonuc[0]["COUNT()"];
  }

  Future<int> lenghtCategoryNotes(int categoryID) async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> sonuc = await db
        .rawQuery("SELECT COUNT() FROM note WHERE categoryID == $categoryID;");
    return sonuc[0]["COUNT()"];
  }

  Future<List<Category>> getCategoryList() async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> categoryMapList =
        await db.query("category", where: "categoryID != 0");
    List<Category> categoryList = [];
    for (Map<String, dynamic> map in categoryMapList) {
      categoryList.add(Category.fromMap(map));
    }
    return categoryList;
  }

  Future<int> addCategory(Category category) async {
    var db = await _getDatabase();
    var sonuc = await db.insert("category", category.toMap());
    return sonuc;
  }

  Future<int> updateCategory(Category category) async {
    var db = await _getDatabase();
    var sonuc = await db.update("category", category.toMap(),
        where: 'categoryID = ?', whereArgs: [category.categoryID]);
    return sonuc;
  }

  Future<bool> addColumn(
      String tableName, String columnName, String datatype) async {
    try {
      if (counter == 0) {
        counter++;
        var db = await _getDatabase();
        await db.execute("ALTER TABLE $tableName ADD $columnName $datatype;");
        Map<String, dynamic> settingsMap = {
          "categoryID": 0,
          "categoryTitle": "Settings",
          "categoryColor": null
        };
        await db.insert("category", settingsMap);
      }
    } catch (e) {
      debugPrint("addColum Catch: " + e.toString());
      return false;
    }
    return true;
  }

  Future<int> deleteCategory(int categoryID) async {
    var db = await _getDatabase();
    var sonuc = await db
        .delete("category", where: 'categoryID = ?', whereArgs: [categoryID]);
    if (sonuc == 1) {
      int lenght = await lenghtCategoryNotes(categoryID);
      if (lenght > 0) return await deleteNoteCategory(categoryID);
      return 1;
    }
    return sonuc;
  }

  Future<int> deleteNote(int noteID) async {
    var db = await _getDatabase();
    var sonuc =
        await db.delete("note", where: 'noteID = ?', whereArgs: [noteID]);
    return sonuc;
  }

  Future<int> deleteNoteCategory(int categoryID) async {
    Database db = await _getDatabase();
    return await db.delete("note", where: "categoryID = $categoryID");
  }

  Future<List<Note>> getNoteList() async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> noteMapList = await db.rawQuery(
        selectNoteSql + " Where note.categoryID != 0 Order By noteID Asc;");
    List<Note> noteList = [];
    for (Map<String, dynamic> map in noteMapList) {
      noteList.add(Note.fromMap(map));
    }
    return noteList;
  }

  Future<List<Note>> getSearchNoteList(String search) async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> noteMapList = await db.rawQuery(selectNoteSql +
        " Where note.categoryID != 0 And (note.noteTitle Like '%$search%' Or "
            "note.noteContent Like '%$search%') Order By noteID Desc;");
    List<Note> noteList = [];
    for (Map<String, dynamic> map in noteMapList) {
      noteList.add(Note.fromMap(map));
    }
    return noteList;
  }

  Future<List<Note>> getSortNoteList(String suan) async {
    Database db = await _getDatabase();
    List<String> sortList = await readSort();
    int sortBy = int.parse(sortList[0]);
    int orderBy = int.parse(sortList[1]);
    String query = selectNoteSql +
        " Where note.categoryID != 0 And noteTime Like '$suan%' Order By ";
    switch (sortBy) {
      case 0:
        query += "categoryTitle ";
        break;
      case 1:
        query += "noteTitle ";
        break;
      case 2:
        query += "noteContent ";
        break;
      case 3:
        query += "noteTime ";
        break;
      case 4:
        query += "notePriority ";
        break;
    }
    if (orderBy == 0)
      query += "Asc;";
    else
      query += "Desc;";
    List<Map<String, dynamic>> noteMapList = await db.rawQuery(query);
    var noteList = List<Note>.empty(growable: true);
    for (Map<String, dynamic> map in noteMapList) {
      noteList.add(Note.fromMap(map));
    }
    return noteList;
  }

  Future<List<String>> readSort() async {
    List<String> sortList;
    try {
      List<Note> sortNoteList = await getNoteTitleNotesList("Sort");
      String sortContent = sortNoteList[0].noteContent!;
      sortList = sortContent.split("/");
    } catch (e) {
      sortList = ["3", "1"];
    }
    return sortList;
  }

  Future<List<Note>> getCategoryNotesList(int categoryID) async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> noteMapList = await db.rawQuery(selectNoteSql +
        " Where note.categoryID == $categoryID Order By noteID Desc;");
    List<Note> noteList = [];
    for (Map<String, dynamic> map in noteMapList) {
      noteList.add(Note.fromMap(map));
    }
    return noteList;
  }

  Future<List<Note>> getNoteTitleNotesList(String noteTitle) async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> noteMapList = await db.rawQuery(selectNoteSql +
        " Where note.noteTitle == '$noteTitle' Order By noteID Desc;");
    List<Note> noteList = [];
    for (Map<String, dynamic> map in noteMapList) {
      noteList.add(Note.fromMap(map));
    }
    return noteList;
  }

  Future<List<Note>> getSettingsNoteTitleList(String noteTitle) async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> noteMapList = await db.rawQuery(selectNoteSql +
        " Where note.noteTitle == '$noteTitle' And note.categoryID = 0 Order by noteID Desc;");
    List<Note> noteList = [];
    for (Map<String, dynamic> map in noteMapList) {
      noteList.add(Note.fromMap(map));
    }
    return noteList;
  }

  Future<Note> getNoteIDNote(int noteID) async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> noteMapList = await db.rawQuery(selectNoteSql +
        " Where note.noteID == '$noteID' Order By noteID Desc;");
    return Note.fromMap(noteMapList.first);
  }

  Future<int> updateNote(Note note) async {
    var db = await _getDatabase();
    var sonuc = await db.update("note", note.toMap(),
        where: 'noteID = ?', whereArgs: [note.noteID]);
    return sonuc;
  }

  Future<void> updateSettingsNote(Note note) async {
    var db = await _getDatabase();
    await db.execute(
        "UPDATE note SET categoryID = ?, noteTitle = ?, noteContent = ?, noteTime = ?, notePriority = ? WHERE noteTitle = ? AND categoryID = ?",
        [
          note.categoryID,
          note.noteTitle,
          note.noteContent,
          note.noteTime,
          note.notePriority,
          note.noteTitle,
          0
        ]);
  }

  Future<int> addNote(Note note) async {
    var db = await _getDatabase();
    var sonuc = await db.insert("note", note.toMap());
    return sonuc;
  }

  String dateFormat(DateTime dt, int lang) {
    String month = "";
    if (lang == 0) {
      switch (dt.month) {
        case 1:
          month = "January";
          break;
        case 2:
          month = "February";
          break;
        case 3:
          month = "March";
          break;
        case 4:
          month = "April";
          break;
        case 5:
          month = "May";
          break;
        case 6:
          month = "June";
          break;
        case 7:
          month = "July";
          break;
        case 8:
          month = "August";
          break;
        case 9:
          month = "September";
          break;
        case 10:
          month = "October";
          break;
        case 11:
          month = "November";
          break;
        default:
          month = "December";
      }
    } else if (lang == 1) {
      switch (dt.month) {
        case 1:
          month = "Ocak";
          break;
        case 2:
          month = "Şubat";
          break;
        case 3:
          month = "Mart";
          break;
        case 4:
          month = "Nisan";
          break;
        case 5:
          month = "Mayıs";
          break;
        case 6:
          month = "Haziran";
          break;
        case 7:
          month = "Temmuz";
          break;
        case 8:
          month = "Ağustos";
          break;
        case 9:
          month = "Eylül";
          break;
        case 10:
          month = "Ekim";
          break;
        case 11:
          month = "Kasım";
          break;
        default:
          month = "Aralık";
      }
    }

    return month + " " + dt.day.toString() + ", " + dt.year.toString();
  }
}
