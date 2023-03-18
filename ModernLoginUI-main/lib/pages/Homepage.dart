import 'dart:convert';
import 'package:modernlogintute/pages/allowance.dart';
import 'package:modernlogintute/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  bool _isLoading = false;

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
