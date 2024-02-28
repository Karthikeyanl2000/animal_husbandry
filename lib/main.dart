// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:animal_husbandry/services/firebase_service.dart';
import 'package:animal_husbandry/services/notification_service.dart';
import 'package:animal_husbandry/view/login.dart';
import 'package:animal_husbandry/view/main_screen.dart';
import 'package:animal_husbandry/widget/apptheme.dart';
import 'package:animal_husbandry/widget/pageRoutes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hyper_object_box/model/ai.dart';
import 'package:hyper_object_box/model/animal.dart';
import 'package:hyper_object_box/objectbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';


Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message)async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  NotificationService().initNotification();
  objectBox = await ObjectBox.create();
  // Request necessary permissions
  await requestPermissions();
  runApp(
    const MyApp(),
  );


  // // Create an instance of NotificationManager and call the functions
  // NotificationManager notificationManager = NotificationManager();
  // await notificationManager.getAIDates();
  // await notificationManager.getAnimalBirth(event);
  // await notificationManager.getDeliveryDates();
  // await notificationManager.monthlyNotifications();
  // await notificationManager.lastInseminationDates();
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
 // NotificationManager notificationManager = NotificationManager();
  Animal animal = Animal();
  AI event = AI();
  bool showNotification = false;
  late NotificationService notificationService;
  List<Map<String, String>> animalDataList= [];
  bool showSplash = true;
  FireBaseNotificationService fireBaseNotificationService = FireBaseNotificationService();
  //late RemoteMessage message;



  @override
  void initState() {
    super.initState();
    initialize();
    checkSession();
    notificationService = NotificationService();
    fireBaseNotificationService.requestNotificationPermissions();
    fireBaseNotificationService.firebaseInit();
    fireBaseNotificationService.getDeviceToken().then((value) {
      print("DeviceToken:$value");
      String deviceToken = value.toString();
      FireBaseNotificationService.requestDeviceToken(deviceToken);
    });
    fireBaseNotificationService.isTokenRefresh();
    requestPermissions();
   // initNotificationManager();

  }

  void initialize() async{
    await Future.delayed(const Duration(seconds: 5));
    FlutterNativeSplash.remove();
    setState(() {
      showSplash = false;
    });
  }

  // Future<void> initNotificationManager() async {
  //   await notificationManager.getAIDates();
  //   await notificationManager.lastInseminationDates();
  //   await notificationManager.getAnimalBirth(event);
  //   await notificationManager.monthlyNotifications();
  //   await notificationManager.getDeliveryDates();
  // }

  bool isLoggedIn = false;


  ///Check Session For User Login
  void checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    if(savedUsername != null) {
      final response = await http.post(
        Uri.parse('${AppTheme.baseUrl}/session'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mobileNumber': savedUsername,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('message')) {
          if (responseData['message'] == 'Login Successful') {
            setState(() {
              isLoggedIn = true;
              fireBaseNotificationService.getDeviceToken().then((value) {
                String deviceToken = value.toString();
                FireBaseNotificationService.requestDeviceToken(deviceToken);
              });
            });
          } else if (responseData['message'] == 'Redirect to payment service') {
            isLoggedIn = false;
            AppTheme.showSnackBar(context, "your validity is expired");
          }
          else {
            setState(() {
              isLoggedIn = false;
            });
          }
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Animal Husbandry',
      routes: myRoutes,
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: showSplash
          ? const ProgressIndicator() : (isLoggedIn ? MainScreen() : const Login()),
    );
  }
}


Future<void> requestPermissions() async {
  final notificationStatus = await Permission.notification.request();
  final cameraStatus = await Permission.camera.request();
  final storageStatus = await Permission.storage.request();
  PermissionStatus phoneStatus = await Permission.phone.request();

  if (notificationStatus.isDenied) {
    await Permission.notification.request();
  }
  else if (cameraStatus.isDenied) {
    await Permission.camera.request();
  }
  else if (storageStatus.isDenied) {
    await Permission.storage.request();
  }
  else if( phoneStatus.isDenied){
    await Permission.phone.request();
  }
}

class ProgressIndicator extends StatefulWidget {
  const ProgressIndicator({super.key});

  @override
  State<ProgressIndicator> createState() =>
      _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
      setState(() {});
    });
    controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Align(
              child:  CircularProgressIndicator(
                value: controller.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}