import 'package:flutter/material.dart';
import 'package:mrnote/models/note.dart';
import 'package:mrnote/models/settings.dart';
import 'package:mrnote/services/database_helper.dart';

import '../const.dart';
import '../ui/Note_Detail/note_detail.dart';
import 'Platform_Duyarli_Alert_Dialog/platform_duyarli_alert_dialog.dart';

class BuildNoteList extends StatefulWidget {
  final bool? isSorted;
  final int? categoryID;

  BuildNoteList({this.categoryID, this.isSorted});

  @override
  _BuildNoteListState createState() => _BuildNoteListState();
}

class _BuildNoteListState extends State<BuildNoteList> {
  List<Note> allNotes = [];
  int? categoryID;

  late Map<String, dynamic> texts;

  Map<String, dynamic> english = {
    "Delete": "Delete",
    "_delNote_if": "1 Mr. Note Deleted",
    "_areYouSureforDelete_baslik": "Are you Sure?",
    "_areYouSureforDelete_icerik": "1 Mr. Note will be deleted.",
    "_areYouSureforDelete_anaButonYazisi": "DELETE",
    "_areYouSureforDelete_iptalButonYazisi": "CANCEL",
    "Priority": ["Low", "Medium", "High"],
  };

  Map<String, dynamic> turkish = {
    "Delete": "Kaldır",
    "_delNote_if": "1 Mr. Not Silindi",
    "_areYouSureforDelete_baslik": "Emin misiniz?",
    "_areYouSureforDelete_icerik": "1 Mr. Note silinecek.",
    "_areYouSureforDelete_anaButonYazisi": "SİL",
    "_areYouSureforDelete_iptalButonYazisi": "İPTAL",
    "Priority": ["Düşük", "Orta", "Yüksek"],
  };

  DatabaseHelper databaseHelper = DatabaseHelper();

  bool? isSorted;

  Settings settings = Settings();

  @override
  void initState() {
    super.initState();
    categoryID = widget.categoryID;
    isSorted = widget.isSorted;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    switch (settings.lang) {
      case 0:
        texts = english;
        break;
      case 1:
        texts = turkish;
        break;
    }
    return FutureBuilder(
      future: fillAllNotes(),
      builder: (context, _) => ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: allNotes.length,
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Dismissible(
                  key: Key(allNotes[index].noteID.toString()),
                  onDismissed: (direction) {
                    int noteID = allNotes[index].noteID!;
                    setState(() {
                      allNotes.removeAt(index);
                    });
                    _areYouSureforDelete(noteID);
                  },
                  background: Container(
                    color: Colors.red,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50, left: 100),
                      child: Text(
                        texts["Delete"],
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    child: Container(
                      height: 130,
                      width: size.width,
                      decoration: BoxDecoration(
                          color: settings.switchBackgroundColor(),
                          borderRadius: borderRadis1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: 110,
                            width: size.width * 0.7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: <Widget>[
                                    Text(
                                      allNotes[index].noteTitle.length > 10
                                          ? allNotes[index]
                                                  .noteTitle
                                                  .substring(0, 10) +
                                              "..."
                                          : allNotes[index].noteTitle,
                                      style: headerStyle5,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      databaseHelper.dateFormat(
                                          DateTime.parse(
                                              allNotes[index].noteTime),
                                          settings.lang!),
                                      style: headerStyle3_2,
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  wrapNoteContent(index),
                                  style: headerStyle4,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              _setPriorityIcon(allNotes[index].notePriority),
                              Container(
                                height: 15,
                                width: 15,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(allNotes[index].categoryColor!),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      var result =
                          await _goToDetailPage(context, allNotes[index]);
                      if (result != null) {
                        setState(() {});
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            );
          }),
    );
  }

  Future<void> fillAllNotes() async {
    List<Note> allNotes1;
    if (categoryID != null) {
      if (categoryID == 0) {
        allNotes1 = await databaseHelper.getNoteList();
      } else {
        allNotes1 = await databaseHelper.getCategoryNotesList(categoryID!);
      }
      allNotes1.sort();
    } else if (isSorted != null) {
      String suan = DateTime.now().toString().substring(0, 10);
      allNotes1 = await databaseHelper.getSortNoteList(suan);
    } else {
      allNotes1 = await databaseHelper.getNoteList();
      allNotes1.sort();
    }
    setState(() {
      allNotes = allNotes1;
    });
  }

  Future<void> _areYouSureforDelete(int noteID) async {
    final sonuc = await PlatformDuyarliAlertDialog(
      baslik: texts["_areYouSureforDelete_baslik"],
      icerik: texts["_areYouSureforDelete_icerik"],
      anaButonYazisi: texts["_areYouSureforDelete_anaButonYazisi"],
      iptalButonYazisi: texts["_areYouSureforDelete_iptalButonYazisi"],
    ).goster(context);

    if (sonuc) {
      _delNote(noteID);
    }
  }

  _delNote(int noteID) {
    databaseHelper.deleteNote(noteID).then((deletedID) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(texts["_delNote_if"])));

      setState(() {});
    });
  }

  String wrapNoteContent(int index) {
    if (allNotes[index].noteContent != null) {
      return allNotes[index].noteContent!.length > 50
          ? allNotes[index]
                  .noteContent!
                  .replaceAll("\n", " ")
                  .substring(0, 50) +
              "..."
          : allNotes[index].noteContent!;
    }
    return "";
  }

  _setPriorityIcon(int notePriority) {
    switch (notePriority) {
      case 0:
        return CircleAvatar(
          child: Text(
            texts["Priority"][0],
            style: TextStyle(color: Colors.black, fontSize: 13),
          ),
          backgroundColor: Colors.green,
        );
      case 1:
        return CircleAvatar(
          child: Text(
            texts["Priority"][1],
            style: TextStyle(color: Colors.black, fontSize: 10),
          ),
          backgroundColor: Colors.yellow,
        );
      case 2:
        return CircleAvatar(
            child: Text(
              texts["Priority"][2],
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            backgroundColor: Color(0xFFff0000));
    }
  }

  Future<String?> _goToDetailPage(BuildContext context, Note note) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NoteDetail(
                  updateNote: note,
                )));
    return result;
  }
}
