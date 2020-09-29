import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mrnote/common_widget/platform_duyarli_widget.dart';

class PlatformDuyarliAlertDialog extends PlatformDuyarliWidget {
  final String baslik, icerik, anaButonYazisi, iptalButonYazisi;

  PlatformDuyarliAlertDialog(
      {@required this.baslik,
      @required this.icerik,
      @required this.anaButonYazisi,
      this.iptalButonYazisi});

  Future<bool> goster(BuildContext context) async {
    return Platform.isIOS
        ? await showCupertinoDialog(
            context: context, builder: (context) => this)
        : await showDialog<bool>(
            context: context,
            builder: (context) => this,
            barrierDismissible: false);
  }

  @override
  Widget buildAndroidWidget(BuildContext context) {
    return AlertDialog(
      title: Text(baslik),
      content: Text(icerik, style: TextStyle(fontSize: 20),),
      actions: _dialogButonlariniAyarla(context),
    );
  }

  @override
  Widget buildIOSWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(baslik),
      content: Text(icerik, style: TextStyle(fontSize: 20),),
      actions: _dialogButonlariniAyarla(context),
    );
  }

  List<Widget> _dialogButonlariniAyarla(BuildContext context) {
    final tumButonlar = <Widget>[];

    if (Platform.isIOS) {
      if (iptalButonYazisi != null) {
        tumButonlar.add(CupertinoDialogAction(
          child: Text(iptalButonYazisi, style: TextStyle(fontSize: 20),),
          onPressed: () {Navigator.of(context).pop(false);},
        ));
      }
      tumButonlar.add(CupertinoDialogAction(
        child: Text(anaButonYazisi, style: TextStyle(fontSize: 20),),
        onPressed: () {
          Navigator.of(context).pop(true);
        },
      ));
    } else {
      if (iptalButonYazisi != null) {
        tumButonlar.add(FlatButton(
          child: Text(iptalButonYazisi, style: TextStyle(fontSize: 20),),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ));
      }
      tumButonlar.add(FlatButton(
        child: Text(anaButonYazisi, style: TextStyle(fontSize: 20),),
        onPressed: () {
          Navigator.of(context).pop(true);
        },
      ));
    }

    return tumButonlar;
  }
}
