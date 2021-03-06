import 'dart:io';

import 'package:flutter/services.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/models/note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    var sonuc = await db.query("category", where: "categoryID != 0");

    return sonuc;
  }

  Future<List<Category>> getCategoryList() async {
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

  Future<bool> addColumn(
      String tableName, String columnName, String datatype) async {
    try {
      var db = await _getDatabase();
      await db.execute("ALTER TABLE $tableName ADD $columnName $datatype;");
    } catch (e) {
      print("addColum Catch: " + e.toString());
      return false;
    }
    return true;
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
        "SELECT * FROM Note INNER JOIN category on category.categoryID = note.categoryID WHERE note.categoryID != 0 order by noteID ASC;");

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

  Future<List<Map<String, dynamic>>> getSearchNotes(String search) async {
    var db = await _getDatabase();
    var sonuc = await db.rawQuery(
        "SELECT * FROM Note INNER JOIN category on category.categoryID = note.categoryID WHERE note.categoryID != 0 AND (note.noteTitle LIKE '%$search%' OR note.noteContent LIKE '%$search%') order by noteID Desc;");
    return sonuc;
  }

  Future<List<Note>> getSearchNoteList(String search) async {
    var noteMapList = await getSearchNotes(search);
    var noteList = List<Note>();
    for (Map map in noteMapList) {
      noteList.add(Note.fromMap(map));
    }
    return noteList;
  }

  Future<List<Map<String, dynamic>>> getTodayNotes(String suan) async {
    var db = await _getDatabase();
    var sonuc = await db.rawQuery(
        "SELECT * FROM Note INNER JOIN category on category.categoryID = note.categoryID WHERE note.categoryID != 0 AND noteTime LIKE '$suan%' order by noteID Desc;");
    return sonuc;
  }

  Future<List<Note>> getTodayNoteList(String suan) async {
    var noteMapList = await getTodayNotes(suan);
    var noteList = List<Note>();
    for (Map map in noteMapList) {
      noteList.add(Note.fromMap(map));
    }
    return noteList;
  }

  Future<List<Map<String, dynamic>>> getSortNotes(String suan) async {
    var db = await _getDatabase();
    List<String> sortList = await readSort();
    int sortBy = int.parse(sortList[0]);
    int orderBy = int.parse(sortList[1]);
    String query =
        "SELECT * FROM Note INNER JOIN category on category.categoryID = note.categoryID WHERE note.categoryID != 0 AND noteTime LIKE '$suan%' order by ";
    switch (sortBy) {
      case 0:
        query += "categoryID ";
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
    if (orderBy == 0) {
      query += "ASC;";
    } else {
      query += "DESC;";
    }
    var sonuc = await db.rawQuery(query);
    return sonuc;
  }

  Future<List<Note>> getSortNoteList(String suan) async {
    var noteMapList = await getSortNotes(suan);
    var noteList = List<Note>();
    for (Map map in noteMapList) {
      noteList.add(Note.fromMap(map));
    }
    return noteList;
  }

  Future<List<String>> readSort() async {
    List<String> sortList;
    try {
      List<Note> sortNoteList = await getNoteTitleNotesList("Sort");
      String sortContent = sortNoteList[0].noteContent;
      sortList = sortContent.split("/");
    } catch (e) {
      sortList = ["3", "1"];
    }
    return sortList;
  }

  Future<List<Map<String, dynamic>>> getCategoryNotes(int categoryID) async {
    var db = await _getDatabase();
    var sonuc = await db.rawQuery(
        "SELECT * FROM Note INNER JOIN category on category.categoryID = note.categoryID WHERE note.categoryID == $categoryID ORDER by noteID DESC;");

    return sonuc;
  }

  Future<List<Note>> getCategoryNotesList(int categoryID) async {
    var noteMapList = await getCategoryNotes(categoryID);
    var noteList = List<Note>();
    for (Map map in noteMapList) {
      noteList.add(Note.fromMap(map));
    }
    return noteList;
  }

  Future<List<Note>> getNoteTitleNotesList(String noteTitle) async {
    var noteMapList = await getNoteTitleNotes(noteTitle);
    var noteList = List<Note>();
    for (Map map in noteMapList) {
      noteList.add(Note.fromMap(map));
    }
    return noteList;
  }

  Future<List<Map<String, dynamic>>> getNoteTitleNotes(String noteTitle) async {
    var db = await _getDatabase();
    var sonuc = await db.rawQuery(
        "SELECT * FROM Note INNER JOIN category on category.categoryID = note.categoryID WHERE note.noteTitle == '$noteTitle' ORDER by noteID DESC;");

    return sonuc;
  }

  Future<List<Note>> getNoteIDNotesList(int noteID) async {
    var noteMapList = await getNoteIDNotes(noteID);
    var noteList = List<Note>();
    for (Map map in noteMapList) {
      noteList.add(Note.fromMap(map));
    }
    return noteList;
  }

  Future<List<Map<String, dynamic>>> getNoteIDNotes(int noteID) async {
    var db = await _getDatabase();
    var sonuc = await db.rawQuery(
        "SELECT * FROM Note INNER JOIN category on category.categoryID = note.categoryID WHERE note.noteID == '$noteID' ORDER by noteID DESC;");
    return sonuc;
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

  String dateFormat(DateTime dt, int lang) {
    String month;
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
        case 12:
          month = "December";
          break;
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
        case 12:
          month = "Aralık";
          break;
      }
    }

    return month + " " + dt.day.toString() + ", " + dt.year.toString();
  }
}
