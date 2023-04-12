// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:modernlogintute/pages/Homepage.dart';
import 'pages/login_page.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   Firebase.initializeApp();

//   print("Handling a background message: ${message.messageId}");
// }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // await FirebaseMessaging.instance.subscribeToTopic('family banking');

  // Request permission to receive notifications
  // FirebaseMessaging messaging = FirebaseMessaging.instance;
  // NotificationSettings settings = await messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );

  // String? token = await messaging.getToken(
  //   vapidKey:
  //       "BHOUeQorshDjky_Xw0I6USgr0T2bZ1wwqI6UnbTU2lWJt3XHuK39MYfwraI0adEidH0278MyGEOcMBkLVLPjrAw",
  // );

  // print('User granted permission: ${settings.authorizationStatus}');

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print('Got a message whilst in the foreground!');
  //   print('Message data: ${message.data}');

  //   if (message.notification != null) {
  //     print('Message also contained a notification: ${message.notification}');
  //   }
  // });
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
