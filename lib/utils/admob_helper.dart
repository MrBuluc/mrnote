import 'package:firebase_admob/firebase_admob.dart';

class AdmobHelper {
  static final String appIDCanli = "ca-app-pub-7911331215388037~3186194719";
  static final String appIDTest = FirebaseAdMob.testAppId;
  static final String gecis1Canli = "ca-app-pub-7911331215388037/3124090310";
  static final String banner1Canli = "ca-app-pub-7911331215388037/2729338642";

  static admobInitialize() {
    FirebaseAdMob.instance.initialize(appId: appIDCanli);
  }

  static final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['flutterio', 'notes', 'safely', 'store', 'phone'],
    contentUrl: 'https://www.facebook.com/hakkican.buluc/',
    childDirected: false,
    testDevices: <String>[], // Android emulators are considered test devices
  );

  static InterstitialAd buildInterstitialAd() {
    return InterstitialAd(
      adUnitId: gecis1Canli,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event is $event");
      },
    );
  }

  static BannerAd myBannerAd;

  static BannerAd buildBannerAd() {
    return BannerAd(
      adUnitId: banner1Canli,
      size: AdSize.smartBanner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.loaded) {
          print("Banner yüklendi");
        }
      },
    );
  }
}
