class Note implements Comparable<Note> {
  int noteID;
  int categoryID;
  String categoryTitle;
  int categoryColor;
  String noteTitle;
  String noteContent;
  String noteTime;
  int notePriority;

  Note(this.categoryID, this.noteTitle, this.noteContent, this.noteTime,
      this.notePriority); // when write data

  Note.withID(this.noteID, this.categoryID, this.noteTitle, this.noteContent,
      this.noteTime, this.notePriority); //when read data

  Note.fromMap(Map<String, dynamic> map) {
    this.noteID = map["noteID"];
    this.categoryID = map["categoryID"];
    this.categoryTitle = map["categoryTitle"];
    this.categoryColor =
        map["categoryColor"] != null ? map["categoryColor"] : 4293914607;
    this.noteTitle = map['noteTitle'];
    this.noteContent = map['noteContent'];
    this.noteTime = map['noteTime'];
    this.notePriority = map['notePriority'];
  }

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

  @override
  int compareTo(Note other) {
    if (this.notePriority > other.notePriority) {
      return -1;
    } else if (this.notePriority < other.notePriority) {
      return 1;
    } else {
      return 0;
    }
  }
}
