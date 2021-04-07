import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mrnote/models/settings.dart';

import '../../services/admob_helper.dart';

class DeveloperPage extends StatefulWidget {
  @override
  _DeveloperPageState createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  Settings settings = Settings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Geliştirici Sayfası"),
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
                    value: settings.adOpen,
                    onChanged: (value) {
                      if (!value) {
                        AdmobHelper.myBannerAd.dispose();
                      }
                      setState(() {
                        settings.adOpen = value;
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
}
