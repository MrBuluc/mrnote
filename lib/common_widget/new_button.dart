import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:mrnote/const.dart';
import 'package:mrnote/ui/Note_Detail/note_detail.dart';

class NewButton extends StatefulWidget {
  final Color closedColor;
  final int lang;
  final int? categoryID;
  final int? categoryColor;

  NewButton(
      {required this.lang,
      required this.closedColor,
      this.categoryID,
      this.categoryColor});

  @override
  State<NewButton> createState() => _NewButtonState();
}

class _NewButtonState extends State<NewButton> {
  late String text;

  @override
  Widget build(BuildContext context) {
    switch (widget.lang) {
      case 0:
        text = "+New";
        break;
      case 1:
        text = "+Yeni";
        break;
    }
    return OpenContainer(
      onClosed: (result) {
        if (result != null) setState(() {});
      },
      transitionType: ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) => NoteDetail(
        categoryID: widget.categoryID,
        categoryColor: widget.categoryColor,
      ),
      closedElevation: 6,
      closedColor: widget.closedColor,
      closedBuilder: (BuildContext context, VoidCallback _) => Text(
        text,
        style: headerStyle2,
      ),
    );
  }
}
