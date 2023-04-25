// import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sms/flutter_sms.dart';
// import 'package:flutter_nfc/flutter_nfc.dart';
import 'package:http/http.dart' as http;
import 'package:modernlogintute/components/my_textfield.dart';
import 'package:modernlogintute/pages/Homepage.dart';
import 'package:modernlogintute/pages/Registrationpage.dart';
import 'package:modernlogintute/services/local_notifications.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/cupertino.dart';

// import 'package:permission_handler/permission_handler.dart';

// Future<void> requestNotificationPermission() async {
//   final PermissionStatus permissionStatus =
//       await Permission.notification.request();
//   if (permissionStatus == PermissionStatus.denied) {
//     // handle denied permission
//     print("permission denied");
//   } else
//     print("permission granted");
// }

class LoginForm {
  String username;
  String password;
  String? token;
  LoginForm(
      {required this.username, required this.password, required this.token});

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'token': token,
      };
}

class LoginPage extends StatefulWidget {
  @override
  Loginpage createState() => Loginpage();
}

class Loginpage extends State<LoginPage> {
  //StatelessWidget {
  // LoginPage({super.key});
  // LoginPage.ensureInitialized();
  // text editing controllers
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String? fcm_token;
  // static const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
  //   'channelId', // your channel id
  //   'com.example.modernlogintute', // your channel name
  //   importance: Importance.high,
  //   priority: Priority.high,
  //   enableVibration: true,
  //   playSound: true,
  // );

  // // create the notification channel
  // const NotificationChannel notificationChannel = NotificationChannel(
  //   'channelId', // your channel id
  //   'channelName', // your channel name
  //   'channelDescription', // your channel description
  //   importance: Importance.high,
  // );

  Future<dynamic> login(LoginForm form) async {
    // https://fbsbanking.herokuapp.com/
    // getDeviceToken();
    // form.username = form.username + token_global;

    print(form.token);
    print(form.username);

    final url = Uri.parse(
        'http://127.0.0.1:8000/login_flutter'); // insert correct API endpoint
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(form.toJson());
    final response = await http.post(url, headers: headers, body: body);
    dynamic user;
    if (response.statusCode == 200) {
      // Successful login
      print("successfully logged in");
      // print(json.decode(response.body)[0]);
      user = json.decode(response.body)[0];
    } else {
      // Failed login
      // throw Exception('Failed to login');
      print('Failed to login');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Failed to login'),
            content: Text('Please check your credentials and try again.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    print(user);
    return user;
  }

  String notificationMsg = "waiting for notifications";

  @override
  void initState() {
    if (Platform.isAndroid || Platform.isIOS) {
      // TODO: implement initState
      super.initState();
      // requestNotificationPermission();
      LocalNotificationService.initilize();

      // Terminated State
      FirebaseMessaging.instance.getInitialMessage().then((event) {
        if (event != null) {
          setState(() {
            notificationMsg =
                "${event.notification!.title} ${event.notification!.body} I am coming from terminated state";
          });
        }
      });

      // Foreground State
      FirebaseMessaging.onMessage.listen((event) {
        LocalNotificationService.showNotificationOnForeground(event);
        setState(() {
          notificationMsg =
              "${event.notification!.title} ${event.notification!.body} I am coming from foreground";
        });
      });

      // background State
      FirebaseMessaging.onMessageOpenedApp.listen((event) {
        setState(() {
          notificationMsg =
              "${event.notification!.title} ${event.notification!.body} I am coming from background";
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const SizedBox(height: 50),

              // logo
              Text(
                'Family Banking',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(
                Icons.account_balance,
                size: 100,
              ),

              const SizedBox(height: 10),

              // welcome!
              Text(
                'Welcome!',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              // username textfield
              MyTextField(
                controller: usernameController,
                hintText: 'Username',
                obscureText: false,
                prefixicon: Icon(Icons.person),
              ),

              const SizedBox(height: 10),

              // password textfield
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
                prefixicon: Icon(Icons.lock),
              ),

              const SizedBox(height: 10),

              // forgot password?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // sign in button
              // MyButton(onTap: login()),
              ElevatedButton(
                onPressed: () async {
                  if (Platform.isAndroid) {
                    fcm_token = await FirebaseMessaging.instance.getToken();
                  } else {
                    fcm_token = "";
                  }
                  final form = LoginForm(
                    username: usernameController.text.trim(),
                    password: passwordController.text.trim(),
                    token: fcm_token,
                  );
                  dynamic user = await login(form);
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Homepage(user: user)),
                    );
                  }
                  ;
                },
                child: Text('Login'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 7, 7, 7)),
                ),
              ),

              // const SizedBox(height: 25),

              // const SizedBox(height: 25),
              // not a member? register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  // FloatingActionButton(
                  //   onPressed: onPressed,
                  //   tooltip: 'register',
                  // ),
                  TextButton(
                    onPressed: () {
                      // String message = "register";
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RegistrationPage(message: "register")),
                      );
                    },
                    child: Text(
                      'Register',
                      style:
                          TextStyle(color: Color.fromARGB(255, 211, 191, 11)),
                    ),
                  )
                  // const Text(
                  //   'Register now',
                  //   style: TextStyle(
                  //     color: Colors.blue,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
