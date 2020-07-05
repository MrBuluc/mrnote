class Note {
  int noteID;
  int categoryID;
  String categoryTitle;
  String noteTitle;
  String noteContent;
  String noteTime;
  int notePriority;

  Note(this.categoryID, this.noteTitle, this.noteContent, this.noteTime,
      this.notePriority); // when write data

  Note.withID(this.noteID, this.categoryID, this.noteTitle, this.noteContent,
      this.noteTime, this.notePriority); //when read data

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map["noteID"] = noteID;
    map["categoryID"] = categoryID;
    map['noteTitle'] = noteTitle;
    map['noteContent'] = noteContent;
    map['noteTime'] = noteTime;
    map['notePriority'] = notePriority;

    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    this.noteID = map["noteID"];
    this.categoryID = map["categoryID"];
    this.categoryTitle = map["categoryTitle"];
    this.noteTitle = map['noteTitle'];
    this.noteContent = map['noteContent'];
    this.noteTime = map['noteTime'];
    this.notePriority = map['notePriority'];
  }

  @override
  String toString() {
    return 'Note{noteID: $noteID, categoryID: $categoryID, categoryTitle: $categoryTitle, noteTitle: $noteTitle, noteContent: $noteContent, noteTime: $noteTime, notePriority: $notePriority}';
  }
}