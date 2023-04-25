import 'dart:convert';
import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:modernlogintute/pages/allowance.dart';
import 'package:modernlogintute/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modernlogintute/pages/statement.dart';
import 'package:modernlogintute/services/local_notifications.dart';
// import 'package:firebase_messaging_web/firebase_messaging_web.dart';
// import 'package:firebase_core_web/firebase_core_web.dart';
// import 'package:flutter_web_plugins/flutter_web_plugins.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:modernlogintute/services/local_notifications.dart';

import 'package:nfc_manager/nfc_manager.dart';
import 'Registrationpage.dart';
import 'bill.dart';
import 'debit.dart';
import 'chat.dart';

class userForm {
  List user;
  // String password;

  userForm({required this.user});

  Map<String, dynamic> toJson() => {
        'user': user,
      };
}

class Homepage extends StatefulWidget {
  @override
  dynamic user;
  Homepage({required this.user});
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _msg = TextEditingController();
  String notificationMsg = "waiting for notifications";
  late double _balance = 0;

  // double _balance = double.parse(widget.user[0]["Balance"]);

  // bool _isLoading = false;
  late List<dynamic> itemList = [];

  Future<dynamic> nfc_handle(user) async {
    print("nfc_handle function called");
    final form = userForm(
      user: user,
    );
    final url =
        Uri.parse('http://127.0.0.1:8000/nfc'); // insert correct API endpoint
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(form.toJson());
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      // Successful NFC payment
      print("successful");
      // print(json.decode(response.body)[0]);
    } else {
      throw Exception('Failed');
    }
  }

  Future<dynamic> statement(user) async {
    final form = userForm(
      user: user,
    );
    final url = Uri.parse(
        'http://127.0.0.1:8000/statement'); // insert correct API endpoint
    final headers = {'Content-Type': 'application/json'};

    final body = json.encode(form.toJson());
    final response = await http.post(url, headers: headers, body: body);
    dynamic statement;
    if (response.statusCode == 200) {
      // Successful logout
      statement = json.decode(response.body);
      print(statement);
      print("successfully sent Get Statement POST");

      // final token = json.decode(response.body)['token'];
      // Save the token to local storage or global state
    } else {
      // Failed login
      throw Exception('Failed to send');
    }
    return statement;
  }

  Future<void> logout(user) async {
    // List<Map<String, dynamic>> user = [];
    // List user = [];

    print(user.runtimeType);
    final form = userForm(
      user: user,
    );
    final url = Uri.parse(
        'http://127.0.0.1:8000/logout'); // insert correct API endpoint
    final headers = {'Content-Type': 'application/json'};
    // for (dynamic item in user1) {
    //   user.add(item.toJson());
    // }
    // print(user);
    final body = json.encode(form.toJson());
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Successful logout
      print("successfully sent Logout POST");
      // final token = json.decode(response.body)['token'];
      // Save the token to local storage or global state
    } else {
      // Failed login
      throw Exception('Failed to logout');
    }
  }

  @override
  // void initState() {
  //   if (Platform.isAndroid || Platform.isIOS) {
  //     // TODO: implement initState
  //     super.initState();
  //     LocalNotificationService.initilize();
  //     _balance = double.parse(widget.user[0]["Balance"]);
  //     print(_balance);
  //     // Terminated State
  //     FirebaseMessaging.instance.getInitialMessage().then((event) {
  //       if (event != null) {
  //         setState(() {
  //           notificationMsg =
  //               "${event.notification!.title} ${event.notification!.body} I am coming from terminated state";
  //         });
  //       }
  //     });

  //     // Foregrand State
  //     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //       // LocalNotificationService.showNotificationOnForeground(event);
  //       print("here");
  //       print(message.notification);
  //       print("here1");

  //       print(
  //           'Received message: ${message.notification?.title} - ${message.notification?.body}');
  //       print("here2");

  //       // setState(() {
  //       //   notificationMsg =
  //       //       "${message.notification.title} ${message.notification.body} I am coming from foreground";
  //       // });
  //     });

  //     // background State
  //     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //       print(
  //           'Received message: ${message.notification!.title} - ${message.notification!.body}');

  //       // setState(() {
  //       //   notificationMsg =
  //       //       "${message.notification.title} ${message.notification.body} I am coming from background";
  //       // });
  //     });
  //   }
  // }

  late String img;
  @override
  Widget build(BuildContext context) {
    if (_balance == 0) {
      _balance = double.parse(widget.user[0]["Balance"]);
    }
    if (Platform.isAndroid || Platform.isIOS) {
      img = "lib/images/background9.png";
    } else {
      img = "lib/images/background10.png";
    }
    return Scaffold(
        // : AssetImage("assets/images/background.jpg"),
        // appBar: AppBar(
        //   title: const Text('Homepage'),
        // ),
        body: //_isLoading
            // ? Center(child: CircularProgressIndicator())

            Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(img),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: SafeArea(
                        child: ElevatedButton.icon(
                      onPressed: () async {
                        await logout(widget.user);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 77, 105, 230),
                      ),
                      icon: Icon(Icons.logout),
                      label: Text(
                        'Logout',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    )),
                  ),
                  Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome, ' + widget.user[0]['Username'],
                            style: TextStyle(
                              color: Color.fromARGB(255, 77, 105, 230),
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Text(
                          //   'Current Balance:',
                          //   style: TextStyle(
                          //     color: Colors.grey[700],
                          //     fontSize: 30,
                          //     fontWeight: FontWeight.w600,
                          //   ),
                          // ),
                          // Text(
                          //   // widget.user[0]["Balance"],
                          //   _balance.toString(),
                          //   style: TextStyle(
                          //     color: Colors.grey[700],
                          //     fontSize: 23,
                          //   ),
                          // ),

                          SizedBox(height: 5),
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                  width: 299,
                                  height: 168,
                                  child: ClipRect(
                                    child: Stack(
                                      children: [
                                        Image.asset(
                                          'lib/images/gradient_card4.png', // replace with your own image file
                                          fit: BoxFit.fill,
                                        ),
                                        Positioned(
                                          top: 20,
                                          left: 22,
                                          child: Text(
                                            'Savings Account',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 248, 247, 247),
                                              fontSize: 19,
                                              letterSpacing: 4,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 45,
                                          left: 22,
                                          child: Text(
                                            widget.user[0]['Account'],
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 248, 247, 247),
                                              fontSize: 14,
                                              letterSpacing: 4,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 60,
                                          left: 22,
                                          child: Text(
                                            'Savings Account',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 248, 247, 247),
                                                fontSize: 16,
                                                letterSpacing: 1,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                        Positioned(
                                          top: 130,
                                          right: 22,
                                          child: Text(
                                            "AED " + _balance.toString(),
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 248, 247, 247),
                                              fontSize: 24,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 115,
                                          left: 22,
                                          child: Text(
                                            'Card Holder',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 248, 247, 247),
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 135,
                                          left: 22,
                                          child: Text(
                                            widget.user[0]['Username'],
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 248, 247, 247),
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (widget.user[0]['Privilege'] == "Main") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RegistrationPage(
                                          message: "family",
                                          user: widget.user)),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 77, 105, 230),
                            ),
                            icon: Icon(Icons.person_add),
                            label: Text(
                              'Add Family',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color.fromARGB(255, 255, 255, 255)),
                            ),
                          ),

                          const SizedBox(height: 5),

                          ElevatedButton.icon(
                            onPressed: () async {
                              if (widget.user[0]['Privilege'] == "Main") {
                                dynamic result = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return MyBillPopup(user: widget.user);
                                  },
                                );
                                setState(() {
                                  if (result != null)
                                    _balance = _balance - result;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 77, 105, 230),
                            ),
                            icon: Icon(Icons.receipt),
                            label: Text(
                              'Pay Bills',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color.fromARGB(255, 255, 255, 255)),
                            ),
                          ),
                          const SizedBox(height: 5),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (widget.user[0]['Privilege'] == "Main") {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ChatScreen(user: widget.user);
                                  },
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 77, 105, 230),
                            ),
                            icon: Icon(Icons.chat_bubble_sharp),
                            label: Text(
                              'Chatbot',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color.fromARGB(255, 255, 255, 255)),
                            ),
                          ),
                          const SizedBox(height: 5),
                          ElevatedButton.icon(
                            onPressed: () {
                              print(widget.user[0]['Privilege']);
                              if (widget.user[0]['Privilege'] == "Main") {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return MydebitPopup(user: widget.user);
                                  },
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 77, 105, 230),
                            ),
                            icon: Icon(Icons.payments_sharp),
                            label: Text(
                              'Add Debit',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color.fromARGB(255, 255, 255, 255)),
                            ),
                          ),

                          const SizedBox(height: 5),
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (widget.user[0]['Privilege'] == "Main") {
                                dynamic result = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return MyallowancePopup(user: widget.user);
                                  },
                                );

                                setState(() {
                                  if (result != null) {
                                    _balance = _balance - result;
                                  }
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 77, 105, 230),
                            ),
                            icon: Icon(Icons.send),
                            label: Text(
                              'Send Money',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color.fromARGB(255, 255, 255, 255)),
                            ),
                          ),
                          const SizedBox(height: 5),
                          ElevatedButton.icon(
                            onPressed: () async {
                              List<dynamic> stat = await statement(widget.user);

                              itemList.add(stat);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return StatementPopup(
                                      user: widget.user,
                                      itemList: itemList[0][0]);
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 77, 105, 230),
                            ),
                            icon: Icon(Icons.text_snippet_outlined),
                            label: Text(
                              'Statement',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color.fromARGB(255, 255, 255, 255)),
                            ),
                          ),
                          const SizedBox(height: 5),

                          Visibility(
                            visible: (Platform.isAndroid || Platform.isIOS),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (Platform.isAndroid || Platform.isIOS) {
                                  // Check availability
                                  bool isAvailable =
                                      await NfcManager.instance.isAvailable();
                                  print("in");
                                  print(isAvailable);
                                  // Start Session
                                  NfcManager.instance.startSession(
                                    // print("hey")
                                    onDiscovered: (NfcTag tag) async {
                                      // await
                                      await nfc_handle(widget.user);
                                      setState(() {
                                        _balance = _balance - 20.0;
                                      });
                                      if (tag != null) {
                                        print("found");
                                        // Ndef ndef = await tag.readNdef();
                                        // NdefMessage message = ndef.cachedMessage;
                                      } else
                                        print("not found");
                                      NfcManager.instance.stopSession();
                                      // Do something with an NfcTag instance.
                                    },
                                  );
                                  // Stop Session
                                  // NfcManager.instance.stopSession();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 77, 105, 230),
                              ),
                              icon: Icon(Icons.tap_and_play_outlined),
                              label: Text(
                                'NFC',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                            ),
                          )
                          // ElevatedButton.icon(
                          //   onPressed: () async {
                          //     if (Platform.isAndroid || Platform.isIOS) {
                          //       // Check availability
                          //       bool isAvailable =
                          //           await NfcManager.instance.isAvailable();
                          //       print("in");
                          //       print(isAvailable);
                          //       // Start Session
                          //       NfcManager.instance.startSession(
                          //         // print("hey")
                          //         onDiscovered: (NfcTag tag) async {
                          //           // await
                          //           await nfc_handle(widget.user);
                          //           setState(() {
                          //             _balance = _balance - 20.0;
                          //           });
                          //           if (tag != null) {
                          //             print("found");
                          //             // Ndef ndef = await tag.readNdef();
                          //             // NdefMessage message = ndef.cachedMessage;
                          //           } else
                          //             print("not found");
                          //           NfcManager.instance.stopSession();
                          //           // Do something with an NfcTag instance.
                          //         },
                          //       );
                          //       // Stop Session
                          //       // NfcManager.instance.stopSession();
                          //     }
                          //   },
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor:
                          //         Color.fromARGB(255, 77, 105, 230),
                          //   ),
                          //   icon: Icon(Icons.tap_and_play_outlined),
                          //   label: Text(
                          //     'NFC',
                          //     style: TextStyle(
                          //         fontFamily: 'Poppins',
                          //         color: Color.fromARGB(255, 255, 255, 255)),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ])));
  }
}
