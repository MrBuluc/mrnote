import 'dart:io';

import 'package:mrnote/models/category.dart';
import 'package:mrnote/models/notes.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  factory DatabaseHelper() {
    if (_database == null) {
      _databaseHelper = DatabaseHelper.internal();
      return _databaseHelper;
    } else {
      return _databaseHelper;
    }
  }

  DatabaseHelper.internal();

  Future<Database> _getDatabase() async {
    if (_database == null) {
      _database = await _initializeDatabase();
      return _database;
    } else {
      return _database;
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

  Future<List<Map<String, dynamic>>> getCategories() async {
    var db = await _getDatabase();
    var sonuc = await db.query("category");

    return sonuc;
  }

  Future<List<Category>> getCategoryList() async{
    var categoryMapList = await getCategories();
    var categoryList = List<Category>();
    for (Map map in categoryMapList) {
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

  Future<int> deleteCategory(int categoryID) async {
    var db = await _getDatabase();
    var sonuc = await db
        .delete("category", where: 'categoryID = ?', whereArgs: [categoryID]);
    return sonuc;
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    var db = await _getDatabase();
    var sonuc = await db.rawQuery(
        "SELECT * FROM Note INNER JOIN category on category.categoryID = note.categoryID order by noteID Desc;");

    return sonuc;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNotes();
    var noteList = List<Note>();
    for (Map map in noteMapList) {
      noteList.add(Note.fromMap(map));
    }
    return noteList;
  }

  Future<List<Map<String, dynamic>>> getFilterNotes(int categoryID) async {
    var db = await _getDatabase();
    var sonuc = await db.rawQuery(
        "SELECT * FROM Note INNER JOIN category on category.categoryID = note.categoryID WHERE note.categoryID == $categoryID ORDER by noteID DESC;");

    return sonuc;
  }

  Future<List<Note>> getFilterNotesList(int categoryID) async {
    var noteMapList = await getFilterNotes(categoryID);
    var noteList = List<Note>();
    for (Map map in noteMapList) {
      noteList.add(Note.fromMap(map));
    }
    print("filterNoteList: $noteList");
    return noteList;
  }

  Future<int> updateNote(Note note) async {
    var db = await _getDatabase();
    var sonuc = await db.update("note", note.toMap(),
        where: 'noteID = ?', whereArgs: [note.noteID]);
    return sonuc;
  }

  Future<int> deleteNote(int noteID) async {
    var db = await _getDatabase();
    var sonuc =
        await db.delete("note", where: 'noteID = ?', whereArgs: [noteID]);
    return sonuc;
  }

  Future<int> addNote(Note note) async {
    var db = await _getDatabase();
    var sonuc = await db.insert("note", note.toMap());
    return sonuc;
  }

  String dateFormat(DateTime dt) {
    String month;
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
      case 12:
        month = "December";
        break;
    }
    return month + " " + dt.day.toString() + ", " + dt.year.toString();
  }
}