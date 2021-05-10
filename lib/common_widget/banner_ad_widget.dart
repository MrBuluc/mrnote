import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  final BannerAd bannerAd;
  final Completer<BannerAd> bannerCompleter;
  final Color currentColor;

  BannerAdWidget({this.bannerAd, this.bannerCompleter, this.currentColor});

  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  @override
  Widget build(BuildContext context) {
    BannerAd bannerAd = widget.bannerAd;

    return FutureBuilder(
        future: widget.bannerCompleter.future,
        builder: (BuildContext context, AsyncSnapshot<BannerAd> snapshot) {
          Widget child;

          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              child = Container();
              break;
            case ConnectionState.done:
              if (snapshot.hasData) {
                child = AdWidget(ad: bannerAd);
              } else {
                child = Text("Error loading $BannerAd");
              }
          }

          return Container(
            width: bannerAd.size.width.toDouble(),
            height: bannerAd.size.height.toDouble(),
            color: widget.currentColor,
            child: child,
          );
        });
  }
}
