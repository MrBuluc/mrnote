import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mrnote/common_widget/banner_ad_widget.dart';
import 'package:mrnote/models/settings.dart';

class DeveloperPage extends StatefulWidget {
  @override
  _DeveloperPageState createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  Settings settings = Settings();

  BannerAd _bannerAd;
  final Completer<BannerAd> bannerAdCompleter = Completer<BannerAd>();

  @override
  void initState() {
    super.initState();
    if (settings.adOpen) {
      adInitialize();
    }
  }

  @override
  void dispose() {
    if (settings.adOpen) {
      disposeAd();
    }
    super.dispose();
  }

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
                        _bannerAd.dispose();
                      }
                      setState(() {
                        settings.adOpen = value;
                      });
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  ),
                ),
              ],
            ),
            if (settings.adOpen)
              BannerAdWidget(
                bannerAd: _bannerAd,
                bannerCompleter: bannerAdCompleter,
                currentColor: Color(4293914607),
              )
          ],
        ),
      ),
    );
  }

  Future<void> adInitialize() async {
    _bannerAd = BannerAd(
        adUnitId: Settings.test ? BannerAd.testAdUnitId : Settings.banner1Canli,
        request: AdRequest(),
        size: AdSize.banner,
        listener: AdListener(onAdLoaded: (Ad ad) {
          print("$BannerAd loaded.");
          bannerAdCompleter.complete(ad as BannerAd);
        }, onAdFailedToLoad: (Ad ad, LoadAdError err) {
          ad.dispose();
          print("Failed to load a banner ad: ${err.message}");
          bannerAdCompleter.completeError(err);
        }));
    Future<void>.delayed(Duration(seconds: 1), () => _bannerAd.load());
  }

  void disposeAd() {
    _bannerAd.dispose();
  }
}
