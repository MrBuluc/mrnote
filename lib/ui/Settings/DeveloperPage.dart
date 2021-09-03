import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mrnote/models/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeveloperPage extends StatefulWidget {
  @override
  _DeveloperPageState createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  Settings settings = Settings();

  AdmobBannerController admobBannerController;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

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
                    onChanged: (value) async {
                      if (!value) {
                        admobBannerController.dispose();
                      }
                      final SharedPreferences prefs = await _prefs;
                      setState(() {
                        settings.adOpen = value;
                        prefs.setBool("adOpen", value);
                      });
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  ),
                ),
              ],
            ),
            if (settings.adOpen)
              Container(
                margin: EdgeInsets.only(bottom: 20.0),
                child: AdmobBanner(
                  adUnitId: Settings.test
                      ? AdmobBanner.testAdUnitId
                      : Settings.banner1Canli,
                  adSize: AdmobBannerSize.BANNER,
                  onBannerCreated: (AdmobBannerController controller) {
                    setState(() {
                      admobBannerController = controller;
                    });
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
