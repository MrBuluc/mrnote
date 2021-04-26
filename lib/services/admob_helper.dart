import 'package:firebase_admob/firebase_admob.dart';
import 'package:mrnote/models/settings.dart';

class AdmobHelper {
  static final String appIDCanli = Settings.appIDCanli;
  static final String appIDTest = FirebaseAdMob.testAppId;
  static final String gecis1Canli = Settings.gecis1Canli;
  static final String banner1Canli = Settings.banner1Canli;

  static final bool test = false;

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
