import 'package:flutter/material.dart';
import 'package:mrnote/common_widget/Platform_Duyarli_Alert_Dialog/platform_duyarli_alert_dialog.dart';
import 'package:mrnote/common_widget/merkez_widget.dart';
import 'package:mrnote/models/category.dart';
import 'package:mrnote/models/note.dart';
import 'package:mrnote/models/settings.dart';
import 'package:mrnote/services/database_helper.dart';

import '../../const.dart';

class NoteDetail extends StatefulWidget {
  final Note? updateNote;
  final int? categoryID;
  final int? categoryColor;

  NoteDetail({this.updateNote, this.categoryID, this.categoryColor});

  @override
  _NoteDetailState createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<Category> allCategories = [];
  late List<String> priority;

  DatabaseHelper databaseHelper = DatabaseHelper();

  late int categoryID, selectedPriority, counter = 0;

  late String noteTitle, noteContent;

  late Map<String, String> texts;
  Map<String, String> english = {
    "_priority0": "Low",
    "_priority1": "Medium",
    "_priority2": "High",
    "Container_Padding1_hintText": "Enter Mr. Note Title",
    "Container_Padding2_hintText": "Enter Mr. Note Content",
    "exit_baslik": "Are You Sure?",
    "exit_icerik": "Save your changes or cancel?",
    "exit_anaButonYazisi": "SAVE",
    "exit_iptalButonYazisi": "CANCEL",
    "categories_warning": "Please create a category!",
  };
  Map<String, String> turkish = {
    "_priority0": "Düşük",
    "_priority1": "Orta",
    "_priority2": "Yüksek",
    "Container_Padding1_hintText": "Mr. Notun Başlığını Girin",
    "Container_Padding2_hintText": "Mr. Notun İçeriğini Girin",
    "exit_baslik": "Emin misiniz?",
    "exit_icerik":
        "Değişikliklerinizi kaydetmek mi yoksa iptal etmek mi istiyorsunuz?",
    "exit_anaButonYazisi": "KAYDET",
    "exit_iptalButonYazisi": "İPTAL",
    "categories_warning": "Lütfen önce bir kategori oluşturun!",
  };

  Settings settings = Settings();

  bool isChanged = false, readed = false;

  late Color backgroundColor;

  Note? updateNote;

  late PlatformDuyarliAlertDialog exitDialog;

  late Size size;

  @override
  void initState() {
    super.initState();
    switch (settings.lang) {
      case 0:
        texts = english;
        break;
      case 1:
        texts = turkish;
        break;
    }
    exitDialog = PlatformDuyarliAlertDialog(
      baslik: texts["exit_baslik"]!,
      icerik: texts["exit_icerik"]!,
      anaButonYazisi: texts["exit_anaButonYazisi"]!,
      iptalButonYazisi: texts["exit_iptalButonYazisi"],
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    priority = [
      texts["_priority0"]!,
      texts["_priority1"]!,
      texts["_priority2"]!,
    ];
    return PopScope(
      // ToDo Test
      onPopInvoked: (bool degisken) async {
        if (isChanged) {
          final sonuc = await exitDialog.goster(context);

          if (sonuc) {
            save(context);
            Navigator.pop(context, false);
          }
        }
        Navigator.pop(context, true);
      },
      child: SafeArea(
        child: SafeArea(
            child: FutureBuilder(
          future: readCategories(),
          builder: (context, _) {
            return Scaffold(
                floatingActionButton: allCategories.isEmpty
                    ? Container()
                    : Visibility(
                        visible: MediaQuery.of(context).viewInsets.bottom == 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FloatingActionButton(
                            onPressed: () {
                              save(context);
                            },
                            backgroundColor: Colors.white,
                            elevation: 5,
                            child: Icon(
                              Icons.save,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                backgroundColor: backgroundColor,
                body: getBody());
          },
        )),
      ),
    );
  }

  void save(BuildContext context) {
    formKey.currentState!.save();
    var suan = DateTime.now();
    if (updateNote == null) {
      databaseHelper
          .addNote(Note(categoryID, noteTitle, noteContent, suan.toString(),
              selectedPriority))
          .then((savedNoteID) {
        if (savedNoteID != 0) {
          Navigator.pop(context, "saved");
        }
      });
    } else {
      databaseHelper
          .updateNote(Note.withID(widget.updateNote!.noteID, categoryID,
              noteTitle, noteContent, suan.toString(), selectedPriority))
          .then((updatedID) {
        if (updatedID != 0) {
          Navigator.pop(context, "updated");
        }
      });
    }
  }

  Future readCategories() async {
    if (counter == 0) {
      allCategories = await databaseHelper.getCategoryList();
      if (widget.updateNote != null) {
        updateNote = widget.updateNote;
        categoryID = updateNote!.categoryID;
        selectedPriority = updateNote!.notePriority;
        backgroundColor = Color(updateNote!.categoryColor!);
      } else {
        selectedPriority = 0;
        if (widget.categoryID != null) {
          categoryID = widget.categoryID!;
          backgroundColor = Color(widget.categoryColor!);
        } else if (allCategories.isNotEmpty) {
          backgroundColor = settings.currentColor!;
          categoryID = allCategories[0].categoryID!;
        }
      }
      readed = true;
      counter++;
    }
  }

  Widget getBody() {
    if (!readed)
      return MerkezWidget(children: [CircularProgressIndicator()]);
    else {
      if (allCategories.isEmpty)
        return Center(
          child: Text(
            texts["categories_warning"]!,
            style: TextStyle(fontSize: 20),
          ),
        );
      return SingleChildScrollView(
        child: Container(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                buildAppBar(),
                buildTitleFormField(),
                buildFormField(),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget buildAppBar() {
    return Container(
      height: 50,
      width: size.width,
      color: Colors.grey.shade100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.close,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
              ),
              onTap: () async {
                if (isChanged) {
                  final sonuc = await exitDialog.goster(context);

                  if (sonuc) {
                    save(context);
                  }
                } else
                  Navigator.pop(context);
              },
            ),
            SizedBox(
              width: size.width * 0.25,
            ),
            dropDown(),
            SizedBox(
              width: size.width * 0.05,
            ),
            dropDownPriority()
          ],
        ),
      ),
    );
  }

  Widget dropDown() {
    return DropdownButton(
      value: categoryID,
      icon: Icon(Icons.keyboard_arrow_down),
      iconSize: 20,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.transparent,
      ),
      onChanged: (selectedCategoryID) {
        isChanged = true;
        setState(() {
          categoryID = selectedCategoryID!;
        });
      },
      items: createCategoryItem(),
    );
  }

  List<DropdownMenuItem<int>> createCategoryItem() {
    return allCategories
        .map((category) => DropdownMenuItem<int>(
              value: category.categoryID,
              child: Text(
                category.categoryTitle,
                style: headerStyle3,
              ),
            ))
        .toList();
  }

  Widget dropDownPriority() {
    return DropdownButton<int>(
      value: selectedPriority,
      icon: Icon(Icons.keyboard_arrow_down),
      iconSize: 20,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        color: Colors.transparent,
      ),
      onChanged: (selectedPriorityID) {
        isChanged = true;
        setState(() {
          selectedPriority = selectedPriorityID!;
        });
      },
      items: priority.map((e) {
        return DropdownMenuItem<int>(
          child: Text(
            e,
            style: headerStyle3_1,
          ),
          value: priority.indexOf(e),
        );
      }).toList(),
    );
  }

  Widget buildTitleFormField() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 5),
      child: TextFormField(
        initialValue: updateNote != null ? updateNote!.noteTitle : "",
        maxLines: null,
        style: headerStyle5,
        cursorColor: Colors.grey.shade600,
        decoration: InputDecoration(
          hintText: texts["Container_Padding1_hintText"],
          hintStyle: headerStyle5,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
        onSaved: (text) {
          noteTitle = text!;
        },
        onChanged: (String value) {
          isChanged = true;
        },
      ),
    );
  }

  buildFormField() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: updateNote != null ? updateNote!.noteContent : "",
            maxLines: null,
            style: headerStyle10,
            cursorColor: Colors.grey.shade800,
            decoration: InputDecoration(
              hintText: texts["Container_Padding2_hintText"],
              hintStyle: headerStyle10,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
            onSaved: (text) {
              noteContent = text!;
            },
            onChanged: (String value) {
              isChanged = true;
            },
          )
        ],
      ),
    );
  }
}
