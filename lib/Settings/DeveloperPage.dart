import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mrnote/utils/admob_helper.dart';

// ignore: must_be_immutable
class DeveloperPage extends StatefulWidget {
  bool adOpen;

  DeveloperPage(this.adOpen);

  @override
  _DeveloperPageState createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Geliştirici Sayfası"),
        actions: <Widget>[
          FlatButton(
            color: Colors.red.shade600,
            textColor: Colors.black,
            child: Text(
              "Save",
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              save(widget.adOpen);
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Reklamları Aç",
                    style: TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  margin: EdgeInsets.all(8),
                  child: Switch(
                    value: widget.adOpen,
                    onChanged: (value) {
                      if (!value) {
                        AdmobHelper.myBannerAd.dispose();
                      }
                      setState(() {
                        widget.adOpen = value;
                      });
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void save(bool adOpen) {
    String result;
    if (adOpen) {
      result = "1";
    } else {
      result = "0";
    }
    Navigator.pop(context, result);
  }
}
