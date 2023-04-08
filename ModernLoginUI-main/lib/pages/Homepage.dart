import 'dart:convert';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:modernlogintute/pages/allowance.dart';
import 'package:modernlogintute/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modernlogintute/pages/statement.dart';
// import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
// import 'package:flutter_nfc/flutter_nfc.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:nfc_manager/nfc_manager.dart';
import 'Registrationpage.dart';
import 'bill.dart';
import 'debit.dart';

class userForm {
  List user;
  // String password;

  userForm({required this.user});

  Map<String, dynamic> toJson() => {
        'user': user,
      };
}

class ChatMessage {
  final String message;
  final bool isUserMessage;

  const ChatMessage({
    required this.message,
    required this.isUserMessage,
  });
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

  bool _isLoading = false;
  late List<dynamic> itemList = [];
  List<ChatMessage> messages = [
    ChatMessage(
      message: 'Hi, I am a chatbot. How can I help you?',
      isUserMessage: false,
    ),
  ];
  // NfcSession session = await FlutterNfcKit.startSession();
  // session.onDiscovered.listen((NfcTag tag) {
  // // Handle the discovered tag
  // String text = await tag.readText();
  // print(text);
  // });
  // await session.stop();
//   void startNFCSession() async {
//   FlutterNfc().startSession(onDiscovered: (NfcTag tag) {
//     // Handle tag data here
//     print(tag);
//   });
// }

  Future<dynamic> statement(user) async {
    // List<Map<String, dynamic>> user = [];
    // List user = [];

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

  Future<void> sendMessage(String message) async {
    messages.add(ChatMessage(
      message: message,
      isUserMessage: true,
    ));
    setState(() {});
    final form = userForm(
      user: widget.user,
    );
    final body = json.encode(form.toJson());

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/chatbot'),
      body: body,
    );
    if (response.statusCode == 200) {
      print(response.body);
      messages.add(ChatMessage(
        message: response.body,
        isUserMessage: false,
      ));
    } else {
      print("welp");
      messages.add(ChatMessage(
        message: 'Oops! Something went wrong.',
        isUserMessage: false,
      ));
    }
    setState(() {});
    print("end of function");
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homepage'),
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
                                builder: (context) =>
                                    RegistrationPage(message: "family")),
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
                      onPressed: () {
                        if (widget.user[0]['Privilege'] == "Main") {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return MyBillPopup(user: widget.user);
                            },
                          );
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

                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Pay',
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
                              return MyallowancePopup(user: widget.user);
                            },
                          );
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
                                user: widget.user, itemList: itemList);
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
                        String message = "This is a test message!";
                        print(message);
                        List<String> recipents = ["00971503437768"];

                        String _result = await sendSMS(
                                message: message,
                                recipients: recipents,
                                sendDirect: true)
                            .catchError((onError) {
                          print(onError);
                        });
                        print(_result);

                        // Check availability
                        bool isAvailable =
                            await NfcManager.instance.isAvailable() ?? false;
                        print("in");
                        print(isAvailable);
                        // Start Session
                        NfcManager.instance.startSession(
                          // print("hey")
                          onDiscovered: (NfcTag? tag) async {
                            // await
                            if (tag != null) {
                              print("not null");
                            } else
                              print("found");
                            // Do something with an NfcTag instance.
                          },
                        );
                        // Stop Session
                        NfcManager.instance.stopSession();
                        print("out");
                      },
                      child: Text("NFC"),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        if (widget.user[0]['Privilege'] == "Main") {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 400,
                                  child: Column(
                                    children: [
                                      Builder(
                                        builder: (context) {
                                          return Expanded(
                                            child: ListView.builder(
                                              itemCount: messages.length,
                                              itemBuilder: (context, index) {
                                                final message = messages[index];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Align(
                                                    alignment: message
                                                            .isUserMessage
                                                        ? Alignment.centerRight
                                                        : Alignment.centerLeft,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: message
                                                                .isUserMessage
                                                            ? Colors.blueGrey
                                                            : Colors.grey[300],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        message.message,
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _msg,
                                              decoration: const InputDecoration(
                                                  hintText: 'Type a message'),
                                              // onSubmitted: (value) {
                                              //   print(value);
                                              //   sendMessage(value);
                                              // },
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {});
                                              sendMessage(_msg.text.trim());
                                            },
                                            child: const Text('Send'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                      child: const Text('Open ChatBot'),
                    )
                    // SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
    );
  }

  void debit() {}
}
