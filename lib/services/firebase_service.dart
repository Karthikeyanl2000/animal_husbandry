import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/apptheme.dart';
import 'package:http/http.dart' as http;

class FireBaseNotificationService {
  final FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  int notificationId = 0;

  Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User Granted Permission');
    } else {
      print('User Did Not Grant Permission');
    }
  }

  Future<void> firebaseInitNotification(
      BuildContext context, RemoteMessage remoteMessage) async {
    try {
      AndroidInitializationSettings initializationSettingsAndroid =
          const AndroidInitializationSettings('@mipmap/ic_launcher');

      var initializationSettingsIOS = DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          onDidReceiveLocalNotification: (int id, String? title, String? body,
              String? payload) async {});

      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);

      await localNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (payload) async {},
      );
    } catch (e) {
      // Handle the exception here
      print('Error initializing notifications: $e');
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString(),
      importance: Importance.max,
      showBadge: true,
      playSound: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      androidNotificationChannel.id.toString(),
      androidNotificationChannel.name.toString(),
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher', // Ensure correct icon path
    );

    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    notificationId++;
    Future.delayed(Duration.zero, () {
      localNotificationsPlugin.show(
        notificationId,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
      );
    });
  }

  //Initial Message Pushing
  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        print("Title: ${message.notification!.title}");
        print("Body: ${message.notification!.body}");
        showNotification(message);
      } else {
        print("Message notification is null");
      }
    });
  }


  //Get FCM Device Token
   Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }
  //Refresh FCM Device Token
  void isTokenRefresh()async{
    messaging.onTokenRefresh.listen((eventToken) {
      eventToken.toString();
      print('Refresh:$eventToken');
    });
  }

  static Future<void> requestDeviceToken(String deviceToken) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? mobileNumber = preferences.getString('username');
    if (mobileNumber != null) {
      final url = '${AppTheme.baseUrl}/request_device_token';
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        'device_token': deviceToken,
        'mobile_number': mobileNumber,
      });

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: body,
        );

        if (response.statusCode == 200) {
          print('Device token registered successfully');
        } else {
          print('Failed to register device token: ${response.body}');
        }
      } catch (error) {
        print('Error registering device token: $error');
      }
    }
  }
}

