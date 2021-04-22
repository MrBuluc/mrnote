import 'package:firebase_admob/firebase_admob.dart';

class AdmobHelper {
  static final String appIDCanli = "ca-app-pub-2104543393026445~1095002395";
  static final String appIDTest = FirebaseAdMob.testAppId;
  static final String gecis1Canli = "ca-app-pub-2104543393026445/8249430070";
  static final String banner1Canli = "ca-app-pub-2104543393026445/3436743639";

  static final bool test = true;

  static admobInitialize() {
    FirebaseAdMob.instance.initialize(appId: test ? appIDTest : appIDCanli);
  }

  static final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['flutterio', 'notes', 'safely', 'store', 'phone'],
    contentUrl: 'https://www.facebook.com/hakkican.buluc/',
    childDirected: false,
    testDevices: <String>[], // Android emulators are considered test devices
  );

  static InterstitialAd buildInterstitialAd() {
    return InterstitialAd(
      adUnitId: test ? InterstitialAd.testAdUnitId : gecis1Canli,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event is $event");
      },
    );
  }

  static BannerAd myBannerAd;

  static BannerAd buildBannerAd() {
    return BannerAd(
      adUnitId: test ? BannerAd.testAdUnitId : banner1Canli,
      size: AdSize.smartBanner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.loaded) {
          print("Banner yüklendi");
        } else {
          print("BannedAd event is $event");
        }
      },
    );
  }
}
