class Note implements Comparable<Note> {
  int? noteID;
  late int categoryID;
  String? categoryTitle;
  int? categoryColor;
  late String noteTitle;
  late String? noteContent;
  late String noteTime;
  late int notePriority;

  Note(this.categoryID, this.noteTitle, this.noteContent, this.noteTime,
      this.notePriority); // when write data

  Note.withID(this.noteID, this.categoryID, this.noteTitle, this.noteContent,
      this.noteTime, this.notePriority); //when read data

  Note.fromMap(Map<String, dynamic> map) {
    noteID = map["noteID"];
    categoryID = map["categoryID"];
    categoryTitle = map["categoryTitle"];
    categoryColor =
        map["categoryColor"] != null ? map["categoryColor"] : 4293914607;
    noteTitle = map['noteTitle'];
    noteContent = map['noteContent'];
    noteTime = map['noteTime'];
    notePriority = map['notePriority'];
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
