import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common_widget/Platform_Duyarli_Alert_Dialog/platform_duyarli_alert_dialog.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  // Handle data message
  final dynamic data = message.data;
  debugPrint("Arka planda gelen data:" + data.toString());
  NotificationHandler.showNotification(data);

  return Future<void>.value();
}

class NotificationHandler {
  FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static final NotificationHandler _singleton = NotificationHandler._internal();

  factory NotificationHandler() {
    return _singleton;
  }

  NotificationHandler._internal();

  BuildContext myContext;

  initializeFCMNotification(BuildContext context) async {
    myContext = context;
    var initializationSettingsAndroid =
        AndroidInitializationSettings("app_icon");
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    _fcm.subscribeToTopic("all");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("onMessage: $message");
      await showNotification(message.data);
    });
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  }

  static Future<void> showNotification(Map<String, dynamic> message) async {
    var bigTextStyleInformation;

    bigTextStyleInformation = BigTextStyleInformation(message["title"],
        htmlFormatBigText: true,
        contentTitle: message["title"],
        htmlFormatContentTitle: true,
        summaryText: message["message"],
        htmlFormatSummaryText: true);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '1234',
        'Duyuru Bildirimleri',
        'Bu kanaldan duyuru bildirimlerini paylaşıyoruz.\n' +
            "Duyurulardan haberdar olmak için bu kanalı açık tutun.",
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        styleInformation: bigTextStyleInformation);

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, message["title"], message["message"], platformChannelSpecifics,
        payload: jsonEncode(message));
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint("notification payload: " + payload);
      Map<String, dynamic> data = await jsonDecode(payload);
      bool sonuc = await PlatformDuyarliAlertDialog(
        baslik: data["title"],
        icerik: data["body"],
        anaButonYazisi: "Evet 🤩",
        iptalButonYazisi: "Hayır 😣",
      ).goster(myContext);

      if (sonuc) {
        String magazaSayfasi =
            "https://play.google.com/store/apps/details?id=hakkicanbuluc.mrnote";
        if (await canLaunch(magazaSayfasi)) {
          await launch(magazaSayfasi);
        } else {
          debugPrint("Could not launch: $magazaSayfasi");
        }
      }
    }
  }
}
