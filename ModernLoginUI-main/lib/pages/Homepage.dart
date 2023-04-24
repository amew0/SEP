import 'dart:convert';
import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_sms/flutter_sms.dart';
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

class UserForm {
  List user;
  // String password;

  UserForm({required this.user});

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

  bool _isLoading = false;
  late List<dynamic> itemList = [];

  Future<dynamic> nfc_handle(user) async {
    print("nfc_handle function called");
    final form = UserForm(
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
    final form = UserForm(
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
    final form = UserForm(
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
  void initState() {
    if (Platform.isAndroid || Platform.isIOS) {
      // TODO: implement initState
      super.initState();
      LocalNotificationService.initilize();
      _balance = double.parse(widget.user[0]["Balance"]);
      print(_balance);
      // Terminated State
      FirebaseMessaging.instance.getInitialMessage().then((event) {
        if (event != null) {
          setState(() {
            notificationMsg =
                "${event.notification!.title} ${event.notification!.body} I am coming from terminated state";
          });
        }
      });

      // Foregrand State
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
    if (_balance == 0) {
      _balance = double.parse(widget.user[0]["Balance"]);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      // widget.user[0]["Balance"],
                      _balance.toString(),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      notificationMsg,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await logout(widget.user);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(
                        'Logout',
                        style:
                            TextStyle(color: Color.fromARGB(255, 211, 191, 11)),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (widget.user[0]['Privilege'] == "Main") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegistrationPage(
                                    message: "family", user: widget.user)),
                          );
                        }
                      },
                      child: Text(
                        'Family Member',
                        style:
                            TextStyle(color: Color.fromARGB(255, 211, 191, 11)),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (widget.user[0]['Privilege'] == "Main") {
                          double result = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return MyBillPopup(user: widget.user);
                            },
                          );
                          print(result);
                          setState(() {
                            _balance = _balance - result;
                          });
                        }
                      },
                      child: Text(
                        'Pay Bills',
                        style:
                            TextStyle(color: Color.fromARGB(255, 211, 191, 11)),
                      ),
                    ),
                    TextButton(
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
                      child: Text(
                        'Chat',
                        style:
                            TextStyle(color: Color.fromARGB(255, 211, 191, 11)),
                      ),
                    ),
                    TextButton(
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
                      child: Text(
                        'Add Debits',
                        style:
                            TextStyle(color: Color.fromARGB(255, 211, 191, 11)),
                      ),
                    ),
                    // TextButton(
                    //   onPressed: () {},
                    //   child: Text(
                    //     'Pay',
                    //     style:
                    //         TextStyle(color: Color.fromARGB(255, 211, 191, 11)),
                    //   ),
                    // ),
                    TextButton(
                      onPressed: () async {
                        if (widget.user[0]['Privilege'] == "Main") {
                          double result = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return MyallowancePopup(user: widget.user);
                            },
                          );

                          setState(() {
                            _balance = _balance - result;
                          });
                        }
                      },
                      child: Text(
                        'Add allowance',
                        style:
                            TextStyle(color: Color.fromARGB(255, 211, 191, 11)),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        List<dynamic> stat = await statement(widget.user);

                        itemList.add(stat);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatementPopup(
                                user: widget.user, itemList: itemList[0][0]);
                          },
                        );
                      },
                      child: Text(
                        'get statement',
                        style:
                            TextStyle(color: Color.fromARGB(255, 211, 191, 11)),
                      ),
                    ),
                    TextButton(
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
                      child: Text("NFC"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void debit() {}
}
