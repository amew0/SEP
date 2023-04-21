import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:modernlogintute/pages/Homepage.dart';
import 'pages/login_page.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> backroundHandler(RemoteMessage message) async {
  print(" This is message from the background");
  print(message.notification!.title);
  print(message.notification!.body);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    await Firebase.initializeApp();
    FirebaseMessaging _msg = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(backroundHandler);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

// class MyFirebaseMessagingService extends FirebaseMessagingService {
//   @override
//   Future<void> onMessage(RemoteMessage message) async {
//     print('Got a message with title: ${message.notification?.title}');
//     print('And body: ${message.notification?.body}');
//   }
// }
